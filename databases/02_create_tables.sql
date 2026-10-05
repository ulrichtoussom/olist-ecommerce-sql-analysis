
-- Premiere etape : creation des tables dans la base de données 
-- Sans ajout de contraintes pour le moment
-- j'ai eu du mal a creer les cle composés dans order_items et order_payments, donc je les ai supprimés pour le moment ? est ce que c'est une bonne idée ?
CREATE TABLE customers(
    
    customer_id VARCHAR(50) ,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city TEXT,
    customer_state VARCHAR(2)
)


CREATE TABLE products(
    
    product_id VARCHAR(50),
    product_category_name TEXT,
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g  NUMERIC(10,2),
    product_length_cm NUMERIC(10,2),
    product_height_cm NUMERIC(10,2),
    product_width_cm  NUMERIC(10,2)
)

CREATE TABLE geolocation(
    
    geolocation_zip_code_prefix INT,
    geolocation_lat NUMERIC(10,6),
    geolocation_lng NUMERIC(10,6),
    geolocation_city TEXT,
    geolocation_state VARCHAR(2)
)

CREATE TABLE sellers(
    
    seller_id VARCHAR(50),
    seller_zip_code_prefix INT,
    seller_city TEXT,
    seller_state VARCHAR(2)
)

CREATE TABLE categories_name_translations(
    
    product_category_name TEXT,
    product_category_name_english TEXT
)

CREATE TABLE orders(
    
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
)

CREATE TABLE order_items(
    
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2)
)

CREATE TABLE order_payments(
    
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value NUMERIC(10,2)
)

