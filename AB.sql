CREATE TABLE Books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    author VARCHAR(100) NOT NULL,
    genre VARCHAR(50),
    price NUMERIC(10, 2) NOT NULL,
    stock INT NOT NULL CHECK (stock >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE'
);

CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    mobile VARCHAR(15) NOT NULL,
    country VARCHAR(50) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    city VARCHAR(50) NOT NULL,
    address VARCHAR(255) NOT NULL
);


-- Teszt adatok a Books táblához
INSERT INTO Books (title, author, genre, price, stock) 
VALUES ('Book Title 1', 'Author Name', 'Fiction', 19.99, 10);

-- Teszt adatok a Customers táblához
INSERT INTO Customers (name, email, mobile, country, zip_code, city, address)
VALUES ('John Doe', 'john@example.com', '123456789', 'USA', '10001', 'New York', '123 Main St');

-- Teszt adatok az Orders táblához
INSERT INTO Orders (customer_id, status)
VALUES (1, 'COMPLETED');

-- Teszt adatok az Order_Items táblához
INSERT INTO Order_Items (order_id, book_id, quantity)
VALUES (1, 1, 2);

-- Teszt adatok az Invoices táblához
INSERT INTO Invoices (order_id, total_amount)
VALUES (1, 39.98);


CREATE INDEX idx_customers_country ON Customers(country);
CREATE INDEX idx_customers_zip_code ON Customers(zip_code);
CREATE INDEX idx_customers_city ON Customers(city);

CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE Order_Items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE
);

CREATE INDEX idx_order_items_order_id ON Order_Items(order_id);
CREATE INDEX idx_order_items_book_id ON Order_Items(book_id);

CREATE TABLE Invoices (
    invoice_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    invoice_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE
);

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    genre VARCHAR(50),
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE'
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

INSERT INTO orders (customer_id, order_date, status) VALUES 
(1, '2024-02-15 10:30:00', 'completed'),
(2, '2024-02-16 14:45:00', 'pending'),
(3, '2024-02-17 11:20:00', 'shipped'),
(4, '2024-02-18 16:10:00', 'completed'),
(5, '2024-02-19 09:55:00', 'processing');

-- Adat generáló script

-- 1. Könyvek (Books) táblához tesztadatok generálása
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO Books (title, author, genre, price, stock)
        VALUES (
            'Book Title ' || i,
            'Author Name ' || (i % 10 + 1),  -- 10 különböző szerző
            CASE
                WHEN i % 3 = 0 THEN 'Fiction'
                WHEN i % 3 = 1 THEN 'Non-Fiction'
                ELSE 'Science'
            END,
            ROUND((10 + (RANDOM() * 40))::NUMERIC, 2),  -- Véletlenszerű ár 10 és 50 között
            FLOOR(RANDOM() * 20)  -- Véletlenszerű készlet 0 és 20 között
        );
    END LOOP;
END $$;

-- 2. Vásárlók (Customers) táblához tesztadatok generálása
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..30 LOOP
        INSERT INTO Customers (name, email, mobile, country, zip_code, city, address)
        VALUES (
            'Customer ' || i,
            'customer' || i || '@example.com',
            '555' || LPAD(i::TEXT, 10, '0'),  -- Véletlenszerű mobil szám
            'Country ' || (i % 5 + 1),  -- 5 különböző ország
            LPAD((10000 + i)::TEXT, 5, '0'),  -- Véletlenszerű irányítószám
            'City ' || (i % 10 + 1),  -- 10 különböző város
            'Address ' || i
        );
    END LOOP;
END $$;

-- 3. Rendelések (Orders) táblához tesztadatok generálása
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO Orders (customer_id, status)
        VALUES (
            FLOOR(RANDOM() * 30) + 1,  -- Véletlenszerű vásárló az 1-30 közötti tartományban
            CASE
                WHEN i % 3 = 0 THEN 'COMPLETED'
                WHEN i % 3 = 1 THEN 'PENDING'
                ELSE 'CANCELLED'
            END
        );
    END LOOP;
END $$;

-- 4. Rendelés tételek (Order_Items) táblához tesztadatok generálása
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Order_Items (order_id, book_id, quantity)
        VALUES (
            FLOOR(RANDOM() * 50) + 1,  -- Véletlenszerű rendelés az 1-50 közötti tartományban
            FLOOR(RANDOM() * 50) + 1,  -- Véletlenszerű könyv az 1-50 közötti tartományban
            FLOOR(RANDOM() * 5) + 1  -- Véletlenszerű mennyiség 1 és 5 között
        );
    END LOOP;
END $$;

-- 5. Számlák (Invoices) táblához tesztadatok generálása
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO Invoices (order_id, total_amount)
        VALUES (
            FLOOR(RANDOM() * 50) + 1,  -- Véletlenszerű rendelés az 1-50 közötti tartományban
            ROUND((RANDOM() * 100)::NUMERIC, 2)  -- Véletlenszerű összeg 0 és 100 között
        );
    END LOOP;
END $$;

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    genre VARCHAR(50),
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE'
);

INSERT INTO invoices (order_id, invoice_date, total_amount)
SELECT 
    o.order_id,
    NOW() AS invoice_date,
    SUM(oi.quantity * b.price) AS total_amount
FROM 
    orders o
JOIN 
    order_items oi ON o.order_id = oi.order_id
JOIN 
    books b ON oi.book_id = b.book_id
WHERE 
    o.order_id = :order_id -- Cseréld le az aktuális rendelés azonosítójára
GROUP BY 
    o.order_id;

INSERT INTO konyvek (cim, szerzo_id, isbn, ar, keszlet, kiadas_datuma)
SELECT 
    CONCAT('Könyv cím ', i),
    (i % 50) + 1, -- Choosing a random author ID from the existing authors
    CONCAT('9760000000', LPAD(i::text, 4, '0')), -- ISBN generation
    ROUND(random() * 5000 + 500, 2), -- Random price (500-5500)
    FLOOR(random() * 100 + 1), -- Random stock (1-100)
    CURRENT_DATE - (random() * 1650)::integer -- Publication date
FROM generate_series(1, 1000) AS i;

-- Adat generáló script

-- 1. Könyvek (Books) táblához tesztadatok generálása
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO Books (title, author, genre, price, stock)
        VALUES (
            'Book Title ' || i,
            'Author Name ' || (i % 10 + 1),  -- 10 különböző szerző
            CASE
                WHEN i % 3 = 0 THEN 'Fiction'
                WHEN i % 3 = 1 THEN 'Non-Fiction'
                ELSE 'Science'
            END,
            ROUND((10 + (RANDOM() * 40))::NUMERIC, 2),  -- Véletlenszerű ár 10 és 50 között
            FLOOR(RANDOM() * 20)  -- Véletlenszerű készlet 0 és 20 között
        );
    END LOOP;
END $$;

-- 2. Vásárlók (Customers) táblához tesztadatok generálása
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..30 LOOP
        INSERT INTO Customers (name, email, mobile, country, zip_code, city, address)
        VALUES (
            'Customer ' || i,
            'customer' || i || '@example.com',
            '555' || LPAD(i::TEXT, 10, '0'),  -- Véletlenszerű mobil szám
            'Country ' || (i % 5 + 1),  -- 5 különböző ország
            LPAD((10000 + i)::TEXT, 5, '0'),  -- Véletlenszerű irányítószám
            'City ' || (i % 10 + 1),  -- 10 különböző város
            'Address ' || i
        );
    END LOOP;
END $$;

-- 3. Rendelések (Orders) táblához tesztadatok generálása
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO Orders (customer_id, status)
        VALUES (
            FLOOR(RANDOM() * 30) + 1,  -- Véletlenszerű vásárló az 1-30 közötti tartományban
            CASE
                WHEN i % 3 = 0 THEN 'COMPLETED'
                WHEN i % 3 = 1 THEN 'PENDING'
                ELSE 'CANCELLED'
            END
        );
    END LOOP;
END $$;

-- 4. Rendelés tételek (Order_Items) táblához tesztadatok generálása
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Order_Items (order_id, book_id, quantity)
        VALUES (
            FLOOR(RANDOM() * 50) + 1,  -- Véletlenszerű rendelés az 1-50 közötti tartományban
            FLOOR(RANDOM() * 50) + 1,  -- Véletlenszerű könyv az 1-50 közötti tartományban
            FLOOR(RANDOM() * 5) + 1  -- Véletlenszerű mennyiség 1 és 5 között
        );
    END LOOP;
END $$;

-- 5. Számlák (Invoices) táblához tesztadatok generálása
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO Invoices (order_id, total_amount)
        VALUES (
            FLOOR(RANDOM() * 50) + 1,  -- Véletlenszerű rendelés az 1-50 közötti tartományban
            ROUND((RANDOM() * 100)::NUMERIC, 2)  -- Véletlenszerű összeg 0 és 100 között
        );
    END LOOP;
END $$;
