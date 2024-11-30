document.addEventListener('DOMContentLoaded', async () => {
    const storeItems = document.querySelectorAll('.item-button');
    const purchaseModal = document.getElementById('purchase-modal');
    const purchaseCloseButton = purchaseModal.querySelector('.close-button');
    const purchaseForm = document.getElementById('purchase-form');
    const itemNameElement = document.getElementById('item-name');
    const itemPriceElement = document.getElementById('item-price');
    const storeLink = document.getElementById('store-link'); // The store link in the dropdown
    const storemodal = document.getElementById('store-modal'); // The modal element
    const closeButton = storemodal.querySelector('.close-button'); // The close button in the modal

    storeItems.forEach((item) => {
        item.addEventListener('click', async () => {
            const itemName = item.getAttribute('data-name');
            currentItemPriceUSD = parseFloat(item.getAttribute('data-price')); // Store the price in USD
            itemNameElement.textContent = itemName;

            storemodal.style.display = 'none';
            purchaseModal.style.display = 'flex';
        });
    });

    purchaseForm.addEventListener('submit', (event) => {
        event.preventDefault();
        alert('Thank you for your purchase!');
        purchaseModal.style.display = 'none';
    });

    // Open modal when the store link is clicked
    storeLink.addEventListener('click', (event) => {
        event.preventDefault(); // Prevent default link behavior
        storemodal.style.display = 'flex'; // Show the modal
    });

    // Close purchase modal
    purchaseCloseButton.addEventListener('click', () => {
        purchaseModal.style.display = 'none';
    });

    // Close modal when the close button is clicked
    closeButton.addEventListener('click', () => {
        storemodal.style.display = 'none';
    });
});
