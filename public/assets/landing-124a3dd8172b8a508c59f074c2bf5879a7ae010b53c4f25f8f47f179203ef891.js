document.addEventListener('DOMContentLoaded', async () => {
    const storeItems = document.querySelectorAll('.item-button');
    const purchaseModal = document.getElementById('purchase-modal');
    const purchaseCloseButton = purchaseModal.querySelector('.close-button');
    const purchaseForm = document.getElementById('purchase-form');
    const itemNameElement = document.getElementById('item-name');
    const itemPriceElement = document.getElementById('item-price');
    const storeLink = document.getElementById('store-link');
    const storeModal = document.getElementById('store-modal');
    const closeButton = storeModal.querySelector('.close-button');
    const shardsCountElement = document.querySelector('.shards-count');
    const teleportContainer = document.querySelector('.teleport-container');
    const characterId = teleportContainer.getAttribute('data-character-id');
    //const payShardButton = document.querySelector('#pay-shard-button');
    let currentItemPriceUSD = 0;

    const csrfToken = document.querySelector('[name="csrf-token"]')?.content;
    if (!csrfToken) {
        console.error("CSRF token not found in the page's meta tags.");
        alert("An unexpected error occurred. Please refresh the page and try again.");
        return;
    }

    storeItems.forEach((item) => {
        item.addEventListener('click', () => {
            const itemName = item.getAttribute('data-name');
            currentItemPriceUSD = parseFloat(item.getAttribute('data-price'));
            itemNameElement.textContent = itemName;
            itemPriceElement.dataset.price = currentItemPriceUSD;
            itemPriceElement.textContent = `$${currentItemPriceUSD.toFixed(2)}`;
            storeModal.style.display = 'none';
            purchaseModal.style.display = 'flex';
        });
    });

    purchaseForm.addEventListener('submit', async (event) => {
        event.preventDefault();

        const shardPackage = itemNameElement.textContent;
        const shardsToBuy = parseInt(shardPackage.match(/\d+$/)[0], 10);
        const price = parseFloat(itemPriceElement.dataset.price); // Price from the clicked item
        const cardNumber = purchaseForm.querySelector('#card-number').value.trim();
        const expirationDate = purchaseForm.querySelector('#expiration-date').value.trim();
        const cvv = purchaseForm.querySelector('#cvv').value.trim();

        if (!cardNumber || !expirationDate || !cvv) {
            alert('Please fill in all the required fields.');
            return;
        }

        try {
            const response = await fetch(`/characters/${characterId}/update_shards`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': csrfToken,
                },
                body: JSON.stringify({
                    shard_package: shardPackage,
                    shards: shardsToBuy,
                    price: price,
                    card_number: cardNumber,
                    expiration_date: expirationDate,
                    cvv: cvv,
                }),
            });

            const data = await response.json();

            if (response.ok && data.success) {
                shardsCountElement.textContent = `Shards: ${data.new_shards}`;
                alert(`Purchase successful! Transaction ID: ${data.transaction_id}`);
            } else {
                alert(data.error || 'An error occurred while processing your purchase.');
            }
        } catch (error) {
            console.error('Fetch error:', error);
            alert(`Network error: ${error.message}. Please check your connection and try again.`);
        }

        purchaseModal.style.display = 'none';
    });

    storeLink.addEventListener('click', (event) => {
        event.preventDefault();
        storeModal.style.display = 'flex';
    });

    purchaseCloseButton.addEventListener('click', () => {
        purchaseModal.style.display = 'none';
    });

    closeButton.addEventListener('click', () => {
        storeModal.style.display = 'none';
    });
});
