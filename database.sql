-- E-commerce Database Schema
-- Created for a complete online shopping platform

-- Create database
CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- Users table for customer accounts
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(15),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Categories table for product categorization
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_category_id INT,
    image_url VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- Products table for inventory management
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(200) NOT NULL,
    description TEXT,
    category_id INT NOT NULL,
    brand VARCHAR(100),
    sku VARCHAR(50) UNIQUE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    discount_price DECIMAL(10, 2),
    stock_quantity INT NOT NULL DEFAULT 0,
    min_stock_level INT DEFAULT 5,
    weight DECIMAL(8, 2),
    dimensions VARCHAR(50),
    color VARCHAR(30),
    size VARCHAR(20),
    main_image_url VARCHAR(255),
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    INDEX idx_category (category_id),
    INDEX idx_sku (sku),
    INDEX idx_featured (is_featured)
);

-- Product images table for multiple product photos
CREATE TABLE product_images (
    image_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    alt_text VARCHAR(200),
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- Addresses table for shipping and billing
CREATE TABLE addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    address_type ENUM('shipping', 'billing', 'both') DEFAULT 'shipping',
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    company VARCHAR(100),
    address_line1 VARCHAR(200) NOT NULL,
    address_line2 VARCHAR(200),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Shopping cart table
CREATE TABLE cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_product (user_id, product_id)
);

-- Orders table for purchase tracking
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    order_status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') DEFAULT 'pending',
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    subtotal DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    shipping_cost DECIMAL(10, 2) DEFAULT 0,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    shipping_address_id INT,
    billing_address_id INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id),
    FOREIGN KEY (billing_address_id) REFERENCES addresses(address_id),
    INDEX idx_user (user_id),
    INDEX idx_order_number (order_number),
    INDEX idx_status (order_status)
);

-- Order items table for detailed purchase records
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    product_name VARCHAR(200) NOT NULL, -- Store snapshot of product name
    product_sku VARCHAR(50) NOT NULL,   -- Store snapshot of SKU
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Payment transactions table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_method ENUM('credit_card', 'debit_card', 'paypal', 'stripe', 'bank_transfer', 'cash_on_delivery') NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed', 'cancelled', 'refunded') DEFAULT 'pending',
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    transaction_id VARCHAR(100),
    gateway_response TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    INDEX idx_transaction (transaction_id)
);

-- Reviews and ratings table
CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    order_id INT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200),
    review_text TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT TRUE,
    helpful_votes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    UNIQUE KEY unique_user_product_review (user_id, product_id)
);

-- Wishlist table
CREATE TABLE wishlist (
    wishlist_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_product_wishlist (user_id, product_id)
);

-- Coupons and discounts table
CREATE TABLE coupons (
    coupon_id INT PRIMARY KEY AUTO_INCREMENT,
    coupon_code VARCHAR(50) UNIQUE NOT NULL,
    coupon_name VARCHAR(100) NOT NULL,
    description TEXT,
    discount_type ENUM('percentage', 'fixed_amount') NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL,
    minimum_order_amount DECIMAL(10, 2) DEFAULT 0,
    maximum_discount_amount DECIMAL(10, 2),
    usage_limit INT,
    used_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Coupon usage tracking
CREATE TABLE coupon_usage (
    usage_id INT PRIMARY KEY AUTO_INCREMENT,
    coupon_id INT NOT NULL,
    user_id INT NOT NULL,
    order_id INT NOT NULL,
    discount_amount DECIMAL(10, 2) NOT NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Admin users table for backend management
CREATE TABLE admin_users (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role ENUM('super_admin', 'admin', 'manager', 'support') DEFAULT 'admin',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Inventory tracking table
CREATE TABLE inventory_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    change_type ENUM('restock', 'sale', 'return', 'adjustment', 'damage') NOT NULL,
    quantity_change INT NOT NULL,
    previous_quantity INT NOT NULL,
    new_quantity INT NOT NULL,
    reference_id INT, -- Could be order_id for sales, etc.
    notes TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (created_by) REFERENCES admin_users(admin_id)
);

-- Sample data insertion
-- Insert sample categories
INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Clothing', 'Fashion and apparel'),
('Books', 'Books and educational materials'),
('Home & Garden', 'Home improvement and gardening supplies'),
('Sports', 'Sports equipment and accessories');

-- Insert sample products
INSERT INTO products (product_name, description, category_id, brand, sku, price, stock_quantity) VALUES
('Smartphone XYZ', 'Latest smartphone with advanced features', 1, 'TechBrand', 'PHONE001', 699.99, 50),
('Laptop Pro', 'High-performance laptop for professionals', 1, 'TechBrand', 'LAPTOP001', 1299.99, 25),
('Cotton T-Shirt', 'Comfortable cotton t-shirt', 2, 'FashionCorp', 'TSHIRT001', 29.99, 100),
('Programming Book', 'Learn programming fundamentals', 3, 'EduPublish', 'BOOK001', 49.99, 75),
('Garden Tools Set', 'Complete set of gardening tools', 4, 'GardenPro', 'TOOLS001', 89.99, 30);

-- Create indexes for better performance
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_stock ON products(stock_quantity);
CREATE INDEX idx_orders_date ON orders(created_at);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- Create views for common queries
CREATE VIEW product_summary AS
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    p.discount_price,
    p.stock_quantity,
    c.category_name,
    p.brand,
    COALESCE(AVG(r.rating), 0) as average_rating,
    COUNT(r.review_id) as review_count
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
LEFT JOIN reviews r ON p.product_id = r.product_id
WHERE p.is_active = TRUE
GROUP BY p.product_id;

CREATE VIEW order_summary AS
SELECT 
    o.order_id,
    o.order_number,
    o.order_status,
    o.total_amount,
    o.created_at,
    u.username,
    u.email,
    COUNT(oi.order_item_id) as item_count
FROM orders o
JOIN users u ON o.user_id = u.user_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id;

-- Sample stored procedures
DELIMITER //

-- Procedure to add item to cart
CREATE PROCEDURE AddToCart(
    IN p_user_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE existing_quantity INT DEFAULT 0;
    DECLARE product_stock INT DEFAULT 0;
    
    -- Check product stock
    SELECT stock_quantity INTO product_stock 
    FROM products 
    WHERE product_id = p_product_id AND is_active = TRUE;
    
    IF product_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product not found or inactive';
    END IF;
    
    -- Check if item already in cart
    SELECT quantity INTO existing_quantity 
    FROM cart 
    WHERE user_id = p_user_id AND product_id = p_product_id;
    
    IF existing_quantity IS NULL THEN
        -- Add new item to cart
        IF p_quantity <= product_stock THEN
            INSERT INTO cart (user_id, product_id, quantity) 
            VALUES (p_user_id, p_product_id, p_quantity);
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
        END IF;
    ELSE
        -- Update existing cart item
        IF (existing_quantity + p_quantity) <= product_stock THEN
            UPDATE cart 
            SET quantity = quantity + p_quantity, updated_at = CURRENT_TIMESTAMP
            WHERE user_id = p_user_id AND product_id = p_product_id;
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
        END IF;
    END IF;
END //

-- Procedure to create order from cart
CREATE PROCEDURE CreateOrderFromCart(
    IN p_user_id INT,
    IN p_shipping_address_id INT,
    IN p_billing_address_id INT,
    OUT p_order_id INT
)
BEGIN
    DECLARE v_order_number VARCHAR(50);
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    
    DECLARE cart_cursor CURSOR FOR
        SELECT c.product_id, c.quantity, p.price, p.stock_quantity
        FROM cart c
        JOIN products p ON c.product_id = p.product_id
        WHERE c.user_id = p_user_id AND p.is_active = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    START TRANSACTION;
    
    -- Generate order number
    SET v_order_number = CONCAT('ORD', LPAD(FLOOR(RAND() * 1000000), 6, '0'));
    
    -- Calculate subtotal and validate stock
    OPEN cart_cursor;
    read_loop: LOOP
        FETCH cart_cursor INTO v_product_id, v_quantity, v_price, v_stock;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        IF v_quantity > v_stock THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock for one or more items';
        END IF;
        
        SET v_subtotal = v_subtotal + (v_quantity * v_price);
    END LOOP;
    CLOSE cart_cursor;
    
    -- Create order
    INSERT INTO orders (user_id, order_number, subtotal, total_amount, shipping_address_id, billing_address_id)
    VALUES (p_user_id, v_order_number, v_subtotal, v_subtotal, p_shipping_address_id, p_billing_address_id);
    
    SET p_order_id = LAST_INSERT_ID();
    
    -- Add order items and update stock
    SET done = FALSE;
    OPEN cart_cursor;
    read_loop2: LOOP
        FETCH cart_cursor INTO v_product_id, v_quantity, v_price, v_stock;
        IF done THEN
            LEAVE read_loop2;
        END IF;
        
        INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price, product_name, product_sku)
        SELECT p_order_id, v_product_id, v_quantity, v_price, (v_quantity * v_price), product_name, sku
        FROM products WHERE product_id = v_product_id;
        
        -- Update product stock
        UPDATE products 
        SET stock_quantity = stock_quantity - v_quantity 
        WHERE product_id = v_product_id;
        
        -- Log inventory change
        INSERT INTO inventory_log (product_id, change_type, quantity_change, previous_quantity, new_quantity, reference_id)
        VALUES (v_product_id, 'sale', -v_quantity, v_stock, v_stock - v_quantity, p_order_id);
        
    END LOOP;
    CLOSE cart_cursor;
    
    -- Clear cart
    DELETE FROM cart WHERE user_id = p_user_id;
    
    COMMIT;
END //

DELIMITER ;

-- Create triggers
DELIMITER //

-- Trigger to update product rating when review is added
CREATE TRIGGER update_product_rating AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    -- This would typically update a cached rating field in products table
    -- For now, we'll just ensure the review is properly logged
    INSERT INTO inventory_log (product_id, change_type, quantity_change, previous_quantity, new_quantity, notes)
    VALUES (NEW.product_id, 'adjustment', 0, 0, 0, CONCAT('Review added: Rating ', NEW.rating));
END //

-- Trigger to prevent negative stock
CREATE TRIGGER check_stock_before_update BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity < 0 THEN
        SET NEW.stock_quantity = 0;
    END IF;
END //

DELIMITER ;