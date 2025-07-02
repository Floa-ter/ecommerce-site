// E-commerce Website JavaScript
// Global Variables
let products = [];
let cart = [];
let currentFilter = 'all';

// Sample Products Data (simulating database)
const sampleProducts = [
    {
        id: 1,
        name: "Wireless Headphones",
        price: 99.99,
        category: "electronics",
        description: "High-quality wireless headphones with noise cancellation",
        image: "headphones.jpeg",
        stock: 15
    },
    {
        id: 2,
        name: "Smartphone",
        price: 599.99,
        category: "electronics",
        description: "Latest model smartphone with advanced camera features",
        image: "smartphone.jpeg",
        stock: 8
    },
    {
        id: 3,
        name: "Laptop",
        price: 1299.99,
        category: "electronics",
        description: "Powerful laptop for work and entertainment",
        image: "laptop.jpeg",
        stock: 5
    },
    {
        id: 4,
        name: "Cotton T-Shirt",
        price: 29.99,
        category: "clothing",
        description: "Comfortable cotton t-shirt in various colors",
        image: "t-shirt.jpeg",
        stock: 25
    },
    {
        id: 5,
        name: "Jeans",
        price: 79.99,
        category: "clothing",
        description: "Classic denim jeans with perfect fit",
        image: "jeans.jpeg",
        stock: 18
    },
    {
        id: 6,
        name: "Sneakers",
        price: 129.99,
        category: "clothing",
        description: "Comfortable running sneakers for daily wear",
        image: "sneakers.jpeg",
        stock: 12
    },
    {
        id: 7,
        name: "Programming Book",
        price: 49.99,
        category: "books",
        description: "Complete guide to modern web development",
        image: "book.jpeg",
        stock: 20
    },
    {
        id: 8,
        name: "Fiction Novel",
        price: 19.99,
        category: "books",
        description: "Bestselling fiction novel of the year",
        image: "novel.jpeg",
        stock: 30
    },
    {
        id: 9,
        name: "Garden Tools Set",
        price: 89.99,
        category: "home",
        description: "Complete set of essential garden tools",
        image: "tools-set.jpeg",
        stock: 10
    },
    {
        id: 10,
        name: "Indoor Plant",
        price: 34.99,
        category: "home",
        description: "Beautiful indoor plant to brighten your home",
        image: "indoor-plant.jpeg",
        stock: 22
    },
    {
        id: 11,
        name: "Kitchen Appliance",
        price: 199.99,
        category: "home",
        description: "Multi-functional kitchen appliance for cooking",
        image: "kitchen-appliance.jpeg",
        stock: 7
    },
    {
        id: 12,
        name: "Smart Watch",
        price: 299.99,
        category: "electronics",
        description: "Feature-rich smartwatch with health tracking",
        image: "smart-watch.jpeg",
        stock: 13
    }
];

// Load Products
function displayProducts(productList) {
    const productsGrid = document.getElementById("productsGrid");
    productsGrid.innerHTML = "";

    productList.forEach(product => {
        const productCard = document.createElement("div");
        productCard.className = "product-card";

        productCard.innerHTML = `
            <img src="${product.image}" alt="${product.name}" class="product-image">
            <h3>${product.name}</h3>
            <p>${product.description}</p>
            <p><strong>$${product.price.toFixed(2)}</strong></p>
            <button onclick="addToCart(${product.id})">Add to Cart</button>
        `;

        productsGrid.appendChild(productCard);
    });
}

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

function initializeApp() {
    products = [...sampleProducts];
    loadCartFromStorage();
    displayProducts();
    updateCartCount();
    setupEventListeners();
}

function setupEventListeners() {
    // Close modal when clicking outside
    document.getElementById('cartModal').addEventListener('click', function(e) {
        if (e.target === this) {
            toggleCart();
        }
    });
    
    // Smooth scrolling for navigation links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    // Handle window resize
    window.addEventListener('resize', function() {
        if (window.innerWidth > 768) {
            document.querySelector('.nav').classList.remove('active');
        }
    });
}



// Header Functions
function toggleMenu() {
    const nav = document.querySelector('.nav');
    nav.classList.toggle('active');
}

function toggleSearch() {
    const searchContainer = document.getElementById('searchContainer');
    const searchInput = document.getElementById('searchInput');
    
    searchContainer.classList.toggle('active');
    
    if (searchContainer.classList.contains('active')) {
        setTimeout(() => searchInput.focus(), 300);
    }
}

function searchProducts() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    
    if (searchTerm.trim() === '') {
        displayProducts();
        return;
    }
    
    const filteredProducts = products.filter(product => 
        product.name.toLowerCase().includes(searchTerm) ||
        product.description.toLowerCase().includes(searchTerm) ||
        product.category.toLowerCase().includes(searchTerm)
    );
    
    displayProducts(filteredProducts);
    
    // Show search results message
    const productsGrid = document.getElementById('productsGrid');
    if (filteredProducts.length === 0) {
        productsGrid.innerHTML = `
            <div style="grid-column: 1 / -1; text-align: center; padding: 2rem;">
                <i class="fas fa-search" style="font-size: 3rem; color: #ddd; margin-bottom: 1rem;"></i>
                <h3>No products found</h3>
                <p>Try searching for something else</p>
            </div>
        `;
    }
}

function scrollToProducts() {
    document.getElementById('products').scrollIntoView({
        behavior: 'smooth'
    });
}

// Product Functions
function displayProducts(productsToShow = null) {
    const productsGrid = document.getElementById('productsGrid');
    const productsArray = productsToShow || getFilteredProducts();
    
    if (productsArray.length === 0) {
        productsGrid.innerHTML = `
            <div style="grid-column: 1 / -1; text-align: center; padding: 2rem;">
                <h3>No products available</h3>
            </div>
        `;
        return;
    }
    
    productsGrid.innerHTML = productsArray.map(product => `
        <div class="product-card" data-category="${product.category}">
           <div class="product-image">
    ${product.image.endsWith('.jpeg') || product.image.endsWith('.jpg') || product.image.endsWith('.png') 
        ? `<img src="${product.image}" alt="${product.name}" class="actual-image">` 
        : product.image}
</div>
            <div class="product-info">
                <h3>${product.name}</h3>
                <p>${product.description}</p>
                <div class="product-price">$${product.price.toFixed(2)}</div>
                <div class="stock-info" style="color: ${product.stock < 5 ? '#ff4757' : '#2ed573'}; font-size: 0.9rem; margin-bottom: 1rem;">
                    ${product.stock < 1 ? 'Out of Stock' : `${product.stock} in stock`}
                </div>
                <button class="add-to-cart-btn" onclick="addToCart(${product.id})" ${product.stock < 1 ? 'disabled style="background: #ccc; cursor: not-allowed;"' : ''}>
                    ${product.stock < 1 ? 'Out of Stock' : 'Add to Cart'}
                </button>
            </div>
        </div>
    `).join('');
    
    // Add animation delay for each card
    setTimeout(() => {
        document.querySelectorAll('.product-card').forEach((card, index) => {
            card.style.animationDelay = `${index * 0.1}s`;
        });
    }, 100);
}

function filterProducts(category) {
    currentFilter = category;
    
    // Update active filter button
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
    
    displayProducts();
}

function getFilteredProducts() {
    if (currentFilter === 'all') {
        return products;
    }
    return products.filter(product => product.category === currentFilter);
}

// Cart Functions
function addToCart(productId) {
    const product = products.find(p => p.id === productId);
    
    if (!product || product.stock < 1) {
        showAlert('Product is out of stock!', 'error');
        return;
    }
    
    const existingItem = cart.find(item => item.id === productId);
    
    if (existingItem) {
        if (existingItem.quantity < product.stock) {
            existingItem.quantity += 1;
            showAlert(`${product.name} quantity updated in cart!`, 'success');
        } else {
            showAlert('Maximum stock reached for this item!', 'error');
            return;
        }
    } else {
        cart.push({
            id: product.id,
            name: product.name,
            price: product.price,
            image: product.image,
            quantity: 1,
            maxStock: product.stock
        });
        showAlert(`${product.name} added to cart!`, 'success');
    }
    
    updateCartCount();
    saveCartToStorage();
    updateCartDisplay();
    
    // Add visual feedback to button
    const button = event.target;
    const originalText = button.textContent;
    button.textContent = 'Added!';
    button.style.background = '#2ed573';
    
    setTimeout(() => {
        button.textContent = originalText;
        button.style.background = '';
    }, 1000);
}

function removeFromCart(productId) {
    const itemIndex = cart.findIndex(item => item.id === productId);
    
    if (itemIndex > -1) {
        const itemName = cart[itemIndex].name;
        cart.splice(itemIndex, 1);
        updateCartCount();
        updateCartDisplay();
        saveCartToStorage();
        showAlert(`${itemName} removed from cart!`, 'info');
    }
}

function updateQuantity(productId, change) {
    const item = cart.find(item => item.id === productId);
    
    if (item) {
        const newQuantity = item.quantity + change;
        
        if (newQuantity <= 0) {
            removeFromCart(productId);
        } else if (newQuantity <= item.maxStock) {
            item.quantity = newQuantity;
            updateCartCount();
            updateCartDisplay();
            saveCartToStorage();
        } else {
            showAlert('Maximum stock reached!', 'error');
        }
    }
}

function clearCart() {
    if (cart.length === 0) {
        showAlert('Cart is already empty!', 'info');
        return;
    }
    
    if (confirm('Are you sure you want to clear the cart?')) {
        cart = [];
        updateCartCount();
        updateCartDisplay();
        saveCartToStorage();
        showAlert('Cart cleared successfully!', 'info');
    }
}

function toggleCart() {
    const cartModal = document.getElementById('cartModal');
    cartModal.classList.toggle('active');
    
    if (cartModal.classList.contains('active')) {
        updateCartDisplay();
        document.body.style.overflow = 'hidden';
    } else {
        document.body.style.overflow = '';
    }
}

function updateCartDisplay() {
    const cartItems = document.getElementById('cartItems');
    const cartTotal = document.getElementById('cartTotal');
    
    if (cart.length === 0) {
        cartItems.innerHTML = `
            <div class="empty-cart">
                <i class="fas fa-shopping-cart"></i>
                <h3>Your cart is empty</h3>
                <p>Add some products to get started!</p>
            </div>
        `;
        cartTotal.textContent = '0.00';
        return;
    }
    
    cartItems.innerHTML = cart.map(item => `
        <div class="cart-item">
            <div class="cart-item-image">
    ${item.image.endsWith('.jpeg') || item.image.endsWith('.jpg') || item.image.endsWith('.png')
        ? `<img src="${item.image}" alt="${item.name}" class="cart-image">`
        : item.image}
</div>
            <div class="cart-item-info">
                <h4>${item.name}</h4>
                <div class="cart-item-price">$${item.price.toFixed(2)} each</div>
            </div>
            <div class="quantity-controls">
                <button class="quantity-btn" onclick="updateQuantity(${item.id}, -1)">-</button>
                <span class="quantity">${item.quantity}</span>
                <button class="quantity-btn" onclick="updateQuantity(${item.id}, 1)">+</button>
            </div>
            <button class="remove-btn" onclick="removeFromCart(${item.id})">
                <i class="fas fa-trash"></i>
            </button>
        </div>
    `).join('');
    
    const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    cartTotal.textContent = total.toFixed(2);
}

function updateCartCount() {
    const cartCount = document.getElementById('cartCount');
    const totalItems = cart.reduce((sum, item) => sum + item.quantity, 0);
    cartCount.textContent = totalItems;
    
    // Add animation when count changes
    if (totalItems > 0) {
        cartCount.style.transform = 'scale(1.2)';
        setTimeout(() => {
            cartCount.style.transform = 'scale(1)';
        }, 200);
    }
}

function checkout() {
    if (cart.length === 0) {
        showAlert('Your cart is empty!', 'error');
        return;
    }
    
    const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    
    // Simulate checkout process
    showAlert('Processing your order...', 'info');
    
    setTimeout(() => {
        // Update product stock
        cart.forEach(cartItem => {
            const product = products.find(p => p.id === cartItem.id);
            if (product) {
                product.stock -= cartItem.quantity;
            }
        });
        
        // Clear cart
        cart = [];
        updateCartCount();
        updateCartDisplay();
        saveCartToStorage();
        toggleCart();
        
        // Refresh products display to show updated stock
        displayProducts();
        
        showAlert(`Order placed successfully! Total: $${total.toFixed(2)}`, 'success');
    }, 2000);
}

// Storage Functions
function saveCartToStorage() {
    try {
        localStorage.setItem('ecommerce_cart', JSON.stringify(cart));
    } catch (error) {
        console.log('Local storage not available, using session storage');
        // Fallback: use in-memory storage for this session
    }
}

function loadCartFromStorage() {
    try {
        const savedCart = localStorage.getItem('ecommerce_cart');
        if (savedCart) {
            cart = JSON.parse(savedCart);
        }
    } catch (error) {
        console.log('Could not load cart from storage');
        cart = [];
    }
}

// Form Functions
function submitContactForm(event) {
    event.preventDefault();
    
    const form = event.target;
    const formData = new FormData(form);
    
    // Simulate form submission
    showAlert('Sending message...', 'info');
    
    setTimeout(() => {
        form.reset();
        showAlert('Message sent successfully! We\'ll get back to you soon.', 'success');
    }, 1500);
}

function subscribeNewsletter(event) {
    event.preventDefault();
    
    const form = event.target;
    const email = form.querySelector('input[type="email"]').value;
    
    if (email) {
        showAlert('Subscribing...', 'info');
        
        setTimeout(() => {
            form.reset();
            showAlert('Successfully subscribed to newsletter!', 'success');
        }, 1000);
    }
}

// Utility Functions
function showAlert(message, type = 'info') {
    // Remove existing alerts
    const existingAlerts = document.querySelectorAll('.alert');
    existingAlerts.forEach(alert => alert.remove());
    
    // Create new alert
    const alert = document.createElement('div');
    alert.className = `alert alert-${type}`;
    alert.textContent = message;
    
    // Add to page
    document.body.insertBefore(alert, document.body.firstChild);
    
    // Position the alert
    alert.style.position = 'fixed';
    alert.style.top = '100px';
    alert.style.right = '20px';
    alert.style.zIndex = '3000';
    alert.style.maxWidth = '300px';
    
    // Auto remove after 5 seconds
    setTimeout(() => {
        if (alert.parentNode) {
            alert.remove();
        }
    }, 5000);
    
    // Allow manual removal
    alert.addEventListener('click', () => {
        alert.remove();
    });
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
    }).format(amount);
}

function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Enhanced search with debouncing
const debouncedSearch = debounce(() => {
    searchProducts();
}, 300);

// Update search input to use debounced search
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('input', debouncedSearch);
    }
});

// Keyboard shortcuts
document.addEventListener('keydown', function(e) {
    // Escape key to close modals
    if (e.key === 'Escape') {
        const cartModal = document.getElementById('cartModal');
        if (cartModal.classList.contains('active')) {
            toggleCart();
        }
        
        const searchContainer = document.getElementById('searchContainer');
        if (searchContainer.classList.contains('active')) {
            toggleSearch();
        }
    }
    
    // Ctrl+K to open search
    if (e.ctrlKey && e.key === 'k') {
        e.preventDefault();
        toggleSearch();
    }
});

// Performance optimization: Lazy loading for product images
function observeProductImages() {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                // Load actual images here if using real image URLs
                observer.unobserve(img);
            }
        });
    });
    
    document.querySelectorAll('.product-image').forEach(img => {
        imageObserver.observe(img);
    });
}

// Call this after products are displayed
document.addEventListener('DOMContentLoaded', function() {
    setTimeout(observeProductImages, 1000);
});

// Export functions for potential module use
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        addToCart,
        removeFromCart,
        updateQuantity,
        clearCart,
        checkout,
        filterProducts,
        searchProducts
    };
}