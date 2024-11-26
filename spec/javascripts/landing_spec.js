const { JSDOM } = require('jsdom');

// Simulate DOM before tests
let dom;
let document;
let window;

beforeEach(() => {
    dom = new JSDOM(`
        <!DOCTYPE html>
        <html>
        <body>
            <a id="store-link"></a>
            <div id="store-modal" style="display:none;">
                <span class="close-button"></span>
            </div>
            <div id="purchase-modal" style="display:none;">
                <h3 id="item-name"></h3>
                <p id="item-price"></p>
                <form id="purchase-form"></form>
                <span class="close-button"></span>
            </div>
            <button class="item-button" data-name="Sea Shard (1)" data-price="$0.75 USD"></button>
        </body>
        </html>
    `);

    window = dom.window;
    document = dom.window.document;

    // Mock addEventListener to handle DOMContentLoaded
    const originalAddEventListener = document.addEventListener;
    document.addEventListener = (event, callback) => {
        if (event === 'DOMContentLoaded') {
            callback();
        } else {
            originalAddEventListener.call(document, event, callback);
        }
    };

    // Load your JavaScript file
    require('../../app/assets/javascripts/landing');
});

describe('Landing Page Modals', () => {
    it('opens the store modal when the store link is clicked', () => {
        const storeLink = document.getElementById('store-link');
        const storeModal = document.getElementById('store-modal');

        // Simulate user clicking the store link
        storeLink.click();

        // Assert modal is displayed
        expect(storeModal.style.display).toBe('flex');
    });

    it('populates the purchase modal with correct item details', () => {
        const itemButton = document.querySelector('.item-button');
        const itemName = document.getElementById('item-name');
        const itemPrice = document.getElementById('item-price');
        const purchaseModal = document.getElementById('purchase-modal');

        // Simulate user clicking an item button
        itemButton.click();

        // Assert modal content is updated and modal is displayed
        expect(itemName.textContent).toBe('Sea Shard (1)');
        expect(itemPrice.textContent).toBe('Price: $0.75 USD');
        expect(purchaseModal.style.display).toBe('flex');
    });
});
