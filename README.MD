# PROCESSUS DE TRAITEMENT DE STOCKAGE ET D'ANALYSE DES DONNEES BRUT RECU(FORMAT CSV)
explorer les ressources csv fournis 
explorer les anomalies 
documenter les limitations 
stocker l'ensemble des donnees dans une base de donnee SQL  

L'objectif finalement de cette activité, est de pourvoir effectuer des requettes SQL basique , avancé et metier nous permettant de comprendre davantage notre jeu de donnee . pour ce la nous disposons d'un ensemble de ressource csv que nous allons explorer et analyser. comprendre sa structure, les liaisons entre les differents tableurs , reperer les anomalies , les contraintes et a la fin concstruire un base de donnees qui represente fidelement notre ressource .

Pour realiser cette objectif, nous avons morcelé notre demarche en plusieurs étapes 

# I.)  première Étape : 

Comprendre les donnees avant de concevoir la BD 
Cette etape repond a quatre questions : 
- Quels sont les données disponibles 
- Quels données  qui sont liées 
- Quels est leur qualité
- comment doit on les modelisés dans une Base de données 

##  Analyse de la structure du dataset 

| Table                | Description                         | nbre_ligne  |nbre_colonnes|
| -------------------- | ----------------------------------- |----------   |--------|               
| customers            | Informations sur les clients        |99441        |5       |
| orders               | Historique des commandes            |99441        |8       |
| order_items          | Articles contenus dans une commande |112650       |7       |
| products             | Catalogue produits                  |32951        |9       |
| sellers              | Informations sur les vendeurs       |3095         |4       |
| order_payments       | Paiements réalisés                  |103886       |5       |
| geolocation          | Coordonnées géographiques           |1000163      |5       |
| category_translation | Traduction des catégories           |71           |2       |

## I.1.) Identification des relations 


```bash 
    Customer 
        ----------- 1
        N           Geolocation 


    Customer 
        ---------- N
        1           Order 

    Order
        --------- N |----------> Order_item
        N        Product 

    
    Order_item 
        -------- 1
        N         Sellers

    Orders
        --------- N |------------> Order_payment
        1         payment
```

## I.3) Analyse de la  Qualité

### 3.1) Valeurs Manquantes 

| Colonne affecté | nombre occurence|
| ---- |----|
|product_id                 |     0|
|product_category_name      |   610|
|product_name_lenght        |   610|
|product_description_lenght |   610|
|product_photos_qty         |   610|
|product_weight_g           |     2|
|product_length_cm          |     2|
|product_height_cm          |     2|
|product_width_cm           |     2|

       
    - Orders 

| Colonne affecté | nombre occurence|
| ---- |----|
|order_approved_at              |    160| 
|order_delivered_carrier_date   |   1783|
|order_delivered_customer_date  |   2965|

**Observations** : Les produits possedent 610 lignes dont les informations descriptives sont absentes (Categorie, Nom, Description) ces produits reste neamoins identifiés grace a leur product_id.  
**Consequences** : Ces produits pourrons d'être utilisés dans l'analyse des ventes, mais certaines analyses par catégorie seront incompletes.

De même que pour le fichier Orders, nous *observons* des valeurs manquantes sur les *caractéristiques* (order_approved_at, order_delivered_carrier_date, order_delivered_customer_date), respectivement (160, 1783 et 2965).
La conséquence directe est que les analyses qui impliqueraient ces différentes variables seront difficilement réalisables.

 
### 3.2) Presence de Doublons

Seule la table geolocation presente des doublons ; plus exactement 390005 doublons . 
en explorant de plus prêt, nous obervons plusieurs lignes qui se repetent avec a chaque fois les mêmes valeurs pour chacune des carasteristiques de geolocation 
**Proposition**: Conserver la premiére ou la derniere  occurence pour chaque doublon 
    df_geolocation.drop_duplicates(subset=['nom_de_colonne']
    df.drop_duplicates(subset=['nom_de_colonne'], inplace=True)
    df = df.drop_duplicates(subset=['nom_de_colonne'], keep='last')

### 3.3) Definition des Clés 

| Table       | PK                             | FK                              |
| ----------- | ------------------------------ | ------------------------------- |
| customers   | customer_id                    | -                               |
| orders      | order_id                       | customer_id                     |
| order_items | (order_id, order_item_id)      | order_id, product_id, seller_id |
| products    | product_id                     | -                               |
| sellers     | seller_id                      | -                               |
| payments    | (order_id, payment_sequential) | order_id                        |



### 3.4) Table resolument isolé category_name_translation 
Je ne trouve aucune table avec qui je pourrais mettre cette entite en relation ! Neanmoins Il pourrais servir de table de reference  et etre utilise pour la production de rapport en anglais(Taduction des categories)


### 3.5) Decision de Conception 

| Observation                                            | Décision retenue                                                                                             |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------ |
| Valeurs manquantes dans `products`                     | Conserver les lignes et documenter les limitations des analyses par catégorie.                               |
| Doublons dans `geolocation`                            | Étudier une stratégie de déduplication avant l'import (Consever les premières occurences ) |
| `customer_city` et `customer_state` redondants         | Les conserver pour rester fidèle au dataset et effectuer des contrôles de cohérence avec `geolocation`.      |
| `order_payments` contient déjà les données de paiement | Ne pas créer de table `payment` supplémentaire.                                                              |
| `category_translation` est un dictionnaire             | L'intégrer comme table de référence reliée à `products`.                                                     |


# II) Deuxieme Etape : Conception et Mise en place de la Base de Données PostgreSQL 

A partir de schema ralationnel realisé a l'etape 1, Concevoir une BD Relationnel Robuste prêt a acceuillir les données issues des fichiers CSV .

A la fin de cette etape, nous disposerons de : 
- Une BD Postgres Fonctionnelle 
- De toute les tables créees 
- Des contraintes d'integrités 
- Des clés Primaires et clés etrangères 
- Des index Utiles 
- D'une sturcture facilement reproductible sur n'importe quelle machine 

## 2.1) Choix du SGBD 

Dans le Cadre de projet, PostgreSQL a ete retenu comme SGBD  en raison de sa robustesse, sa conformité au standard SQL , son support des fonctions avancée( CTE, fonction de fenetrage, indexation, vue materialisé) et sa forte adoption dans les environnements professionels 

 ## 2.2) Conception Physique ( Passage du MLD ou Table SQL)

### 2.2.1) Table Customers 

| Colonne                  | Type PostgreSQL | Contraintes      |
| ------------------------ | --------------- | -----------      |
| customer_id              | VARCHAR(50)     | PRIMARY KEY      |
| customer_unique_id       | VARCHAR(50)     | NOT NULL , UNIQUE|
| customer_zip_code_prefix | INTEGER         | NOT NULL         |
| customer_city            | TEXT            | NOT NULL         |customer_state             | CHAR(2)         | NOT NULL         |


### 2.2.2) Table Orders

| Colonne                       | Type        |  Constraintes | Index |
| ------------------------      | ----------- | -------       |       |
| order_id                      | VARCHAR(50) |  PRIMARY KEY  |       |
| customer_id                   | VARCHAR(50) |  FOREING KEY  |  ✅   |
| order_status                  | VARCHAR(20) |  NOT NULL     |       |
| order_purchase_timestamp      | TIMESTAMP   |  NOT NULL     |       |
| order_approved_at             | TIMESTAMP   |               |       |
| order_delivered_carier_date   | TIMESTAMP   |               |       |
| order_delivered_customer_date | TIMESTAMP   |               |       |
| order_estimated_delivery_date | TIMESTAMP   |  NOT NULL     |       |



### 2.2.3) Tables Products 

| Colonne                       | Type              | Constraintes   | Contrainte Metier   |
| ---------                     | ---------         | -------------- | --------            |
| product_id                    | VARCHAR(50)       | PRIMARY KEY    |                     |
| product_category_name         | VARCHAR(50)       |                |                     |
| product_name_length           | INTEGER           |                |                     |
| product_description_lenght    | INTEGER           |                |                     |
| product_photos_qty            | INTEGER           |                |                     |                              
| product_weight_g              | NUMERIC(10,2)     |                |product_weight_g >=0 |
| product_length_cm             | NUMERIC(10,2)     |                |product_length_cm>=0 |     
| product_height_cm             | NUMERIC(10,2)     |                |product_height_cm>=0 |     
| product_width_cm              | NUMERIC(10,2)     |                |product_width_cm>=0  |     


### 2.2.4) Tables Order_item 

| Colonne                       | Type           | Constraintes   | contrainte_metier|
| ---------                     | -------        | -------------- |-------           |
| (order_item_id,order_id)      | VARCHAR(50)    | PRIMARY KEY    |                  |
| order_item_id                 | VARCHAR(50)    | NOT NULL       |                  |
| order_id                      | VARCHAR(50)    | FOREING KEY    |                  |    
| product_id                    | VARCHAR(50)    | FOREING KEY    |                  |     
| seller_id                     | VARCHAR(50)    | FOREING KEY    |                  |       
| shipping_limit_date           | TIMESTAMPS     | NOT NULL       |                  |    
| price                         | NUMERIC(10,2)  | NOT NULL       | price >=0        |
| freight_value                 | NUMERIC(10,2)  | NOT NULL       | freight_value >=0|                   


### 2.2.5) Table Order_payment
| Colonne                       | Type        | Constraintes   | Contrainte Metie  |
| ---------                     | -------     | -------------- | -------           |
|(order_id,payment_sequential)  | VARCHAR(50) | PRIMARY KEY    |                   |
| order_id                      | VARCHAR(50) | FOREING KEY    |                   |
| payment_sequential            | INTEGER     | NOT NULL       |                   |
| payment_type                  | VARCHAR(20)    | NOT NULL       |                   |
| payment_installement          | INTGER      | NOT NULL       |                   |
| payment_value                 | NUMERIC     | NOT NULL       | payment_value>=0  |

### 2.2.6) Tables gealocation 


| Colonne                       | Type        | Constraintes        |
| ---------                     | -------     | --------------      |
| geolocation_zip_code_prefix   | INTEGER     | NOT NULL            |
| geolocation_lat               | NUMERIC     | NOT NULL            |
| geolocation_lng               | NUMERIC     | NOT NULL            |
| geolocation_city              | TEXT        | NOT NULL            |
| geolocation_state             | CHAR(2)     | NOT BULL            |


### 2.2.7) Tables sellers  

| Colonne                       | Type        | Constraintes        |
| ---------                     | -------     | --------------      |
| seller_id                     | VARCHAR(50) | PRIMARY KEY         |
| seller_zip_code_prefix        | INTGER      | NOT NULL            |
| seller_city                   | TEXT        | NOT NULL            |
| seller_state                  | CHAR(2)     | NOT NULL            |

### 2.2.8) Category_name_translation 
| Colonne                       | Type        | Constraintes        |
| ---------                     | -------     | --------------      |
| product_category_name         | VARCHAR(50) | PRIMARY KEY         |
| product_category_name_english | VARCHAR(50) | NOT NULL            |


**Remarque importante** :  
Dans la table order_items , l'on n'est plus succeptible de penser que order_item_id represente la clé primaire , or une clé primaire est l'élèment qui permet de caracteriser une ligne de facon unique . 
Alors la bonne question à ce poser pour trouver la clé d'une table, c'est: **Quels sont les colonnes ou la colonne qui me permettent d'identifier de facon unique une ligne?** .
Dans order_items nous avons order_items qui presente de nombreux doublons et qui represente en realité le numero d'un article dans une commande . un meme produit iphone 15 avec id=1002 peux se retourver dans plusieurs lignes de commande. 
vous convenez donc avec moi que,  ce qui garantir l'unicité d'une ligne ce n'est pas order_item_id, ce n'est non plus (order_id,product_id) mais c'est (order_id, order_item_id) encore appellé clé composée 

En appliquant le même raisonnement sur la table Order_payment, On identifie assez facilement la cle primaire. C'est la cle compose de (order_id,payment_sequential)

# Tableau recaputilatif 

| Table                | PK                                          | FK                              | Nombre de colonnes |
| -------------------- | ------------------------------------------- | ------------------------------- | ------------------ |
| customers            | customer_id                                 | -                               | 5                  |
| orders               | order_id                                    | customer_id                     | 8                  |
| products             | product_id                                  | -                               | 9                  |
| order_items          | (order_id, order_item_id)                   | order_id, product_id, seller_id | 7                  |
| order_payments       | (order_id, payment_sequential)              | order_id                        | 5                  |
| sellers              | seller_id                                   | -                               | 4                  |
| geolocation          | Aucune clé naturelle (présence de doublons) | -                               | 5                  |
| category_translation | product_category_name                       | -                               | 2                  |

## 2.3) Ecriture des Requetes SQL pour implementer concretement Notre BD .

Pour etre modulaire, structuré et tres efficace, nous allons pas ecrire l'ensemble des requetes dans un fichier sql unique. nous allons creer plusieurs fichiers sql avec chacune realisant une tache precise . cette pratique permet non seulement de decouple la structure de notre code sql , le rend plus flexibles et maintenable
- 01_create_database.sql  :  Creation de notre de données 
- 02_create_tables.sql  : Creation unique des tables sans aucune contrainte de facon a ce quel soit tous independante . 
- 03_contraints.sql : ajout des contraintes , cle primaire , cle etrangere et parametre unique , valeur NOT NULL ou pas .
Par convention il ya un ordre d'ecriture(definiton) des contraintes .
    PRIMARY KEY    
        ↓       
     UNIQUE        
        ↓      
      NOT NULL     
        ↓     
       CHECK      
        ↓     
    FOREING KEY     
   
- 04_indexes.sql 
>Les index sont des structures de données créées sur une ou plusieurs colonnes afin d'accélérer l'accès aux données. Contrairement aux clés primaires et étrangères, dont le rôle est d'assurer l'intégrité des données, les index ont pour objectif principal d'améliorer les performances des requêtes. Ils sont généralement créés sur les colonnes fréquemment utilisées dans les clauses WHERE, les JOIN, les ORDER BY ou les GROUP BY. En contrepartie, ils occupent de l'espace disque et ralentissent légèrement les opérations d'insertion, de mise à jour et de suppression, car ils doivent être maintenus à chaque modification des données.

| Choix de L'index | Justificatif |
| -----            |--------      |
|orders(customer_id) | customer_id sera fortement utilisé dans cette table pour faire des recherches ou grouper en fonction du customer_id |
|order_items(product_id) | Toute les analyses produits passeront par cette table il important creer un index sur cette colonne pour accellerer les requettes utilisant cette colonne|
|order_items.seller_id| classement des vendeurs,chiffre d'affaires des vendeurs,délais par vendeur|
|order_payments(order_id) | on pourrait etre tenter de creer un index sur order_id dans la table order_payents mais le fait qu'il soit une cle composé *PRIMARY KEY(order_id, payment_sequential)* de cette table creer automatique un index sur cette colonne il est moin interessant et economique en terme d'espace disque  de ne pas le creer manuellement |
|orders(order_purchase_timestamp) | Toutes les anlayses temporelles l'utiliserons |
| order_status | Tres souvent utilisé pour les filtrages |
| product(product_category_name) | elle sera tres souvent utilisé dans les clauses GROUP BY |




- Import des CSV : transferts les données de nous ressources CSV vers notre base de données 
- 05_quality_checks.sql
- 06_business_queries.sql


# Ordre des contraintes 

