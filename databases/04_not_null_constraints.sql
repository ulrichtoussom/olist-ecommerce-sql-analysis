
-- customers table
aLTER TABLE customers

ALTER COLUMN customer_id
SET NOT NULL;

ALTER COLUMN customer_unique_id 
SET NOT NULL;


ALTER COLUMN customer_zip_code_prefix 
SET NOT NULL;

ALTER COLUMN customer_city 
SET NOT NULL;  

ALTER COLUMN customer_state 
SET NOT NULL;   

-- orders table

ALTER TABLE orders

ALTER COLUMN customer_id
SET NOT NULL;

ALTER COLUMN order_status
SET NOT NULL;

ALTER COLUMN order_purchase_timestamp
SET NOT NULL;

ALTER COLUMN order_estimated_delivery_date
SET NOT NULL;

-- order_items table

ALTER TABLE order_items
ALTER COLUMN order_id
SET NOT NULL;

ALTER COLUMN order_item_id
SET NOT NULL;

ALTER COLUMN shipping_limit_date
SET NOT NULL;

ALTER COLUMN price
SET NOT NULL;

ALTER COLUMN freight_value
SET NOT NULL;

ALTER COLUMN product_id
SET NOT NULL;

-- order_payments table
ALTER TABLE order_payments

ALTER COLUMN payment_sequential
SET NOT NULL;

ALTER COLUMN payment_type
SET NOT NULL;  

ALTER COLUMN payment_installments
SET NOT NULL;

ALTER COLUMN payment_value
SET NOT NULL;

-- geolocation table
ALTER TABLE geolocation

ALTER COLUMN geolocation_zip_code_prefix
SET NOT NULL;

ALTER COLUMN geolocation_lat
SET NOT NULL;

ALTER COLUMN geolocation_lng
SET NOT NULL;

ALTER COLUMN geolocation_city
SET NOT NULL;

ALTER COLUMN geolocation_state
SET NOT NULL;

-- sellers table

ALTER TABLE sellers

ALTER COLUMN seller_zip_code_prefix
SET NOT NULL;

ALTER COLUMN seller_city
SET NOT NULL;

ALTER COLUMN seller_state
SET NOT NULL;

-- category_name_translations table
ALTER TABLE category_name_translations
ALTER COLUMN product_category_name_english
SET NOT NULL;

