
-- add a check constraint to ensure that the order_item_id is unique within each order_id

-- On order_items table
ALTER TABLE order_items 
ADD CONSTRAINT chk_price_positive
CHECK (price >= 0) ;

ALTER TABLE order_items 
ADD CONSTRAINT chk_freight_value_positive
CHECK (freight_value >= 0);

-- On products table
ALTER TABLE products 
ADD CONSTRAINT chk_product_weight_positive
CHECK (product_weight_g >= 0);

ALTER TABLE products 
ADD CONSTRAINT chk_product_length_positive
CHECK (product_length_cm >= 0);

ALTER TABLE products 
ADD CONSTRAINT chk_product_height_positive
CHECK (product_height_cm >= 0);

ALTER TABLE products
ADD CONSTRAINT chk_product_width_positive
CHECK(product_width_cm >= 0);

ALTER TABLE products
ADD CONSTRAINT chk_product_photos_qty_positive
CHECK(product_photos_qty >= 0);

ALTER TABLE products
ADD CONSTRAINT chk_product_name_length_positive
CHECK(product_name_lenght >= 0);

ALTER TABLE products
ADD CONSTRAINT chk_product_description_length_positive
CHECK(product_description_lenght >= 0);



-- On order_payments table
ALTER TABLE order_payments
ADD CONSTRAINT chk_payment_installments_positive
CHECK (payment_installments >0);

ALTER TABLE order_payments
ADD CONSTRAINT chk_payment_value_positive
CHECK (payment_value >= 0);

ALTER TABLE order_payments
ADD CONSTRAINT chk_payment_type_valid
CHECK (
    payment_type IN(
        'credit_card',
        'debit_card',
        'voucher',
        'boleto',
        'not_defined'
    )
)


-- On orders table
ALTER TABLE orders 
ADD CONSTRAINT chk_order_status_valid
CHECK (
    order_status IN (
        'delivered',
        'shipped',
        'canceled',
        'invoiced',
        'processing',
        'unavailable',
        'approved'
    )
)



