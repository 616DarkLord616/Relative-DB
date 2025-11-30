CREATE TABLE Orders (
    o_id INT PRIMARY KEY NOT NULL,
    order_date DATE NOT NULL
);

CREATE TABLE Products (
    p_id SERIAL PRIMARY KEY NOT NULL,
    p_name TEXT NOT NULL UNIQUE,
    price MONEY NOT NULL
);

CREATE TABLE Order_Items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    amount INT NOT NULL DEFAULT 1,
    price MONEY NOT NULL,
    total MONEY NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(o_id),
    FOREIGN KEY (product_id) REFERENCES Products(p_id),
    CHECK (total = amount * price)
);

INSERT INTO Orders (o_id, order_date) VALUES (1, '2025-11-30');
INSERT INTO Orders (o_id, order_date) VALUES (2, '2025-12-01');

INSERT INTO Products (p_name, price) VALUES ('p1', 10.00);
INSERT INTO Products (p_name, price) VALUES ('p2', 20.00);

INSERT INTO Order_Items (order_id, product_id, amount, price, total) VALUES (1, 1, 1, 10.00, 10.00);
INSERT INTO Order_Items (order_id, product_id, amount, price, total) VALUES (1, 2, 1, 20.00, 20.00);

INSERT INTO Order_Items (order_id, product_id, amount, price, total) VALUES (2, 1, 3, 10.00, 30.00);
INSERT INTO Order_Items (order_id, product_id, amount, price, total) VALUES (2, 2, 2, 20.00, 40.00);

SELECT * FROM Orders;
SELECT * FROM Products;
SELECT * FROM Order_Items;
