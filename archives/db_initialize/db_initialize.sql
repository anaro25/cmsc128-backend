CREATE DATABASE IF NOT EXISTS defaultdb;
USE defaultdb;

-- Create UserRoles table
CREATE TABLE UserRoles (
  roleID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  roleName VARCHAR(20) NOT NULL UNIQUE
);

-- Create UserAccounts table
CREATE TABLE UserAccounts (
  accountID INT AUTO_INCREMENT PRIMARY KEY,
  firstName VARCHAR(50) NOT NULL,
  lastName VARCHAR(50) NOT NULL,
  roleID INT UNSIGNED NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  dateCreated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (roleID) REFERENCES UserRoles(roleID)
);

-- Create Categories table
CREATE TABLE Categories (
  C_categoryID INT AUTO_INCREMENT PRIMARY KEY,
  C_categoryName VARCHAR(50) NOT NULL,
  C_categoryStatus ENUM('Active', 'Discontinued') NOT NULL DEFAULT 'Active'
);

-- Create Products table
CREATE TABLE Products (
  P_productCode VARCHAR(10) PRIMARY KEY,
  P_productName VARCHAR(50) NOT NULL,
  P_quantity INT UNSIGNED, -- allow null for now
  P_unitPrice DECIMAL(10,2) CHECK (P_unitPrice > 0), -- allow null for now
  P_sellingPrice DECIMAL(10,2), -- allow null for now
  P_dateAdded TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  P_productStatus ENUM('Available', 'Out of Stock', 'Discontinued') NOT NULL DEFAULT 'Available',
  C_categoryID INT NOT NULL,
  FOREIGN KEY (C_categoryID) REFERENCES Categories(C_categoryID) ON UPDATE CASCADE
);

-- Create ProductStock table
CREATE TABLE ProductStock (
  PS_stockID INT AUTO_INCREMENT PRIMARY KEY,
  P_productCode VARCHAR(10) NOT NULL,
  P_minStockLevel INT UNSIGNED DEFAULT 2,
  P_lastRestockDate DATE NOT NULL,
  FOREIGN KEY (P_productCode) REFERENCES Products(P_productCode) ON UPDATE CASCADE
);

-- Create Suppliers table
CREATE TABLE Suppliers (
  S_supplierID VARCHAR(10) PRIMARY KEY,
  S_supplierName VARCHAR(50) NOT NULL,
  S_supplierStatus ENUM('Active', 'Discontinued') NOT NULL DEFAULT 'Active'
);

-- Create ProductSupplier (Many-to-Many Relationship between Products and Suppliers)
CREATE TABLE ProductSupplier (
  P_productCode VARCHAR(10),
  S_supplierID VARCHAR(10),
  PS_costPrice DECIMAL(10,2) NOT NULL, -- cost price may vary between suppliers
  PRIMARY KEY (P_productCode, S_supplierID),
  FOREIGN KEY (P_productCode) REFERENCES Products(P_productCode) ON UPDATE CASCADE,
  FOREIGN KEY (S_supplierID) REFERENCES Suppliers(S_supplierID) ON UPDATE CASCADE
);

-- Create Brands table
CREATE TABLE Brands (
  B_brandID VARCHAR(10) PRIMARY KEY,
  B_brandName VARCHAR(50) NOT NULL,
  B_brandStatus ENUM('Active', 'Discontinued') NOT NULL DEFAULT 'Active'
);

-- Create ProductBrand (Many-to-Many Relationship between Products and Brands)
CREATE TABLE ProductBrand (
  P_productCode VARCHAR(10),
  B_brandID VARCHAR(10),
  PRIMARY KEY (P_productCode, B_brandID),
  FOREIGN KEY (P_productCode) REFERENCES Products(P_productCode) ON UPDATE CASCADE,
  FOREIGN KEY (B_brandID) REFERENCES Brands(B_brandID) ON UPDATE CASCADE
);

-- Create Deliveries table
CREATE TABLE Deliveries (
  D_deliveryNumber VARCHAR(15) PRIMARY KEY,
  D_deliveryDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  S_supplierID VARCHAR(10) NOT NULL,
  FOREIGN KEY (S_supplierID) REFERENCES Suppliers(S_supplierID) ON UPDATE CASCADE
);

-- Create DeliveryPaymentTypes table
CREATE TABLE DeliveryPaymentTypes (
  D_paymentTypeID INT AUTO_INCREMENT PRIMARY KEY,
  D_paymentName VARCHAR(50) NOT NULL UNIQUE
);

-- Create DeliveryModeOfPayment table
CREATE TABLE DeliveryModeOfPayment (
  D_modeOfPaymentID INT AUTO_INCREMENT PRIMARY KEY,
  D_mopName VARCHAR(50) NOT NULL UNIQUE
);

-- Create DeliveryPaymentStatus table
CREATE TABLE DeliveryPaymentStatus (
  D_paymentStatusID INT AUTO_INCREMENT PRIMARY KEY,
  D_statusName VARCHAR(50) NOT NULL UNIQUE
);

-- Create DeliveryPaymentDetails table
CREATE TABLE DeliveryPaymentDetails (
  DPD_paymentDetailsID INT AUTO_INCREMENT PRIMARY KEY,
  D_deliveryNumber VARCHAR(15) NOT NULL,
  D_deliveryAmount DECIMAL(10,2) NOT NULL,
  D_paymentTypeID INT NOT NULL,
  D_modeOfPaymentID INT NOT NULL,
  D_paymentStatusID INT NOT NULL,
  DPD_dateOfPaymentDue DATE NOT NULL,
  DPD_dateOfPayment1 DATE NOT NULL,
  DPD_dateOfPayment2 DATE,
  DPD_lastModified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (D_deliveryNumber) REFERENCES Deliveries(D_deliveryNumber) ON UPDATE CASCADE,
  FOREIGN KEY (D_paymentTypeID) REFERENCES DeliveryPaymentTypes(D_paymentTypeID) ON UPDATE CASCADE,
  FOREIGN KEY (D_modeOfPaymentID) REFERENCES DeliveryModeOfPayment(D_modeOfPaymentID) ON UPDATE CASCADE,
  FOREIGN KEY (D_paymentStatusID) REFERENCES DeliveryPaymentStatus(D_paymentStatusID) ON UPDATE CASCADE
);

-- Create DeliveryProductDetails table (junction table for Deliveries and Products)
CREATE TABLE DeliveryProductDetails (
  D_productDetailsID INT AUTO_INCREMENT PRIMARY KEY,
  DPD_quantity INT NOT NULL CHECK (DPD_quantity > 0),
  DPD_unitPrice DECIMAL(10,2) CHECK (DPD_unitPrice > 0), -- allow null for now
  D_deliveryNumber VARCHAR(15) NOT NULL,
  P_productCode VARCHAR(10) NOT NULL,
  FOREIGN KEY (D_deliveryNumber) REFERENCES Deliveries(D_deliveryNumber) ON UPDATE CASCADE,
  FOREIGN KEY (P_productCode) REFERENCES Products(P_productCode) ON UPDATE CASCADE
);

-- Create Orders table (per order)
CREATE TABLE Orders (
  O_orderID INT AUTO_INCREMENT PRIMARY KEY,
  O_receiptNumber INT NOT NULL UNIQUE
);

-- Create Discounts table
CREATE TABLE Discounts (
  D_productDiscountID INT PRIMARY KEY,
  D_discountType VARCHAR(10) NOT NULL
);

-- Create OrderDetails (per product)
CREATE TABLE OrderDetails (
  OD_detailID INT AUTO_INCREMENT PRIMARY KEY,
  O_orderID INT NOT NULL,
  P_productCode VARCHAR(10) NOT NULL,
  D_productDiscountID INT NULL,
  OD_quantity INT NOT NULL,
  OD_unitPrice DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (O_orderID) REFERENCES Orders(O_orderID) ON UPDATE CASCADE,
  FOREIGN KEY (P_productCode) REFERENCES Products(P_productCode) ON UPDATE CASCADE,
  FOREIGN KEY (D_productDiscountID) REFERENCES Discounts(D_productDiscountID) ON UPDATE CASCADE
);

-- Create ReturnTypes table
CREATE TABLE ReturnTypes (
  RT_returnTypeID INT AUTO_INCREMENT PRIMARY KEY,
  RT_returnTypeDescription VARCHAR(50) NOT NULL UNIQUE
);

-- Create Returns table
CREATE TABLE Returns (
  R_returnID INT AUTO_INCREMENT PRIMARY KEY,
  P_productCode VARCHAR(10) NOT NULL,
  R_returnTypeID INT NOT NULL,
  R_reasonOfReturn VARCHAR(255) NOT NULL,
  R_dateOfReturn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  R_returnQuantity INT NOT NULL,
  R_discountAmount DECIMAL(10,2) DEFAULT 0.00,
  FOREIGN KEY (P_productCode) REFERENCES Products(P_productCode) ON UPDATE CASCADE,
  FOREIGN KEY (R_returnTypeID) REFERENCES ReturnTypes(RT_returnTypeID) ON UPDATE CASCADE
);

-- Create Transactions table (with order payment details)
CREATE TABLE Transactions (
  T_transactionID INT AUTO_INCREMENT PRIMARY KEY,
  O_orderID INT UNIQUE NOT NULL,  
  T_totalAmount DECIMAL(10,2) NOT NULL,
  D_wholeOrderDiscount DECIMAL(10,2) DEFAULT NULL,
  D_totalProductDiscount DECIMAL(10,2) DEFAULT NULL,
  T_transactionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (O_orderID) REFERENCES Orders(O_orderID) ON UPDATE CASCADE
);

-- Create TransactionTypes table
CREATE TABLE TransactionTypes (
  TT_transactionTypeID INT AUTO_INCREMENT PRIMARY KEY,
  TT_transactionTypeName VARCHAR(20) NOT NULL UNIQUE
);

-- Create Freebies table
CREATE TABLE Freebies (
  F_freebieID INT AUTO_INCREMENT PRIMARY KEY,
  P_productCode VARCHAR(10) NOT NULL,
  F_freebieQuantity INT NOT NULL DEFAULT 0,
  FOREIGN KEY (P_productCode) REFERENCES Products(P_productCode) ON UPDATE CASCADE
);

-- Create TransactionFreebies table
CREATE TABLE TransactionFreebies (
  TF_transactionFreebieID INT AUTO_INCREMENT PRIMARY KEY,
  T_transactionID INT NOT NULL,
  F_freebieID INT NOT NULL,
  FOREIGN KEY (T_transactionID) REFERENCES Transactions(T_transactionID) ON UPDATE CASCADE,
  FOREIGN KEY (F_freebieID) REFERENCES Freebies(F_freebieID) ON UPDATE CASCADE
);

-- Create DeletedTransactions table
CREATE TABLE DeletedTransactions (
  DT_deletionID INT AUTO_INCREMENT PRIMARY KEY,
  T_transactionID INT NOT NULL,
  DT_deletedBy INT NOT NULL,
  DT_deletionTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (T_transactionID) REFERENCES Transactions(T_transactionID) ON UPDATE CASCADE,
  FOREIGN KEY (DT_deletedBy) REFERENCES UserAccounts(accountID) ON UPDATE CASCADE
);