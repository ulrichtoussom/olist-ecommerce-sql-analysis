
-- Voici le Contenu de mon fichier constraints.sql
ALTER TABLE customers 
ADD CONSTRAINT pk_customers 
PRIMARY KEY (customer_id);


ALTER TABLE products
ADD CONSTRAINT pk_products
PRIMARY KEY (product_id);

ALTER TABLE geolocation
ADD CONSTRAINT pk_geolocation
PRIMARY KEY (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng);

ALTER TABLE sellers
ADD CONSTRAINT pk_sellers
PRIMARY KEY (seller_id);

ALTER TABLE category_name_translations
ADD CONSTRAINT pk_category_name_translations
PRIMARY KEY (product_category_name);

ALTER TABLE orders
ADD CONSTRAINT pk_orders
PRIMARY KEY (order_id);

ALTER TABLE order_items
ADD CONSTRAINT pk_order_items
PRIMARY KEY (order_id, order_item_id);

ALTER TABLE order_payments
ADD CONSTRAINT pk_order_payments
PRIMARY KEY (order_id, payment_sequential);

-- add foreign key constraints
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id)
REFERENCES customers (customer_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_orders
FOREIGN KEY (order_id)
REFERENCES orders (order_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_products
FOREIGN KEY (product_id)
REFERENCES products (product_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_sellers
FOREIGN KEY (seller_id)
REFERENCES sellers (seller_id);

ALTER TABLE order_payments
ADD CONSTRAINT fk_order_payments_orders
FOREIGN KEY (order_id)
REFERENCES orders (order_id);

-- add unique constraints
ALTER TABLE customers
ADD CONSTRAINT uq_customer_unique_id
UNIQUE (customer_unique_id);




DROP TABLE IF EXISTS categories_name_translations CASCADE;