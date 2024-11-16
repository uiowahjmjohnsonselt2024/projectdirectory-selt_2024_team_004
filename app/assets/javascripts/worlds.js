document.addEventListener("DOMContentLoaded", function() {
    const buttons = document.querySelectorAll('.btn-option');

    buttons.forEach(button => {
        button.addEventListener('click', function() {
            // Remove 'selected' class from all buttons
            buttons.forEach(b => b.classList.remove('selected'));
            // Add 'selected' class to the clicked button
            button.classList.add('selected');
        });
    });
});
