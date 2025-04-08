# Project Description

## Database Description

Table "organizations"
- Represents customer organizations (wholesale distributors)
- Contains basic organization information (name, tax ID, address)
- Serves as the root entity for most other relationships

Table "users"
- Stores all user accounts in the system
- Supports email and phone authentication
- Includes security features (failed login attempts, account locking)
- Organization association determines access scope
- Indexed on email for fast login lookups

Table  "roles" and "user_roles"
- Implements Role-Based Access Control (RBAC)
- Dynamic permission assignment
- Many-to-many relationship between users and roles

Table "branches"
- Represents physical locations of organizations
- Contains address details
- Organization association provides access control

Table "vendors"
- Stores fuel distributor/vendor information
- Supports preferred vendor designation
- Organization-scoped for proper access control

Table "delivery_orders"
- Core order management table
- Tracks order status and delivery information
- Relationships with branches (delivery location), vendors (distributor), and users (creator)
- Unique index on order_number for fast lookups

Table "order_items"
- Line items for delivery orders
- Contains product, quantity, and pricing information
- Supports notes for special instructions

Table "order_chats"
- Implements messaging per order
- Tracks user who sent each message
- Supports real-time order communication

Table "products"
- Catalog of available products
- Contains pricing and unit information

Table "storages" and "storage_products"
- Tracks storage locations (tanks, warehouses)
- Maintains current inventory levels
- Many-to-many relationship between storages and products

Table "trucks"
- Vehicle management
- Contains vehicle identification information
- Branch association for location tracking

Table "contracts"
- Manages agreements between organizations and vendors
- Tracks status and dates

Table "documents"
- Polymorphic attachment system
- Supports contracts, invoices, and other order documents
- Tracks upload metadata and content type

Table "feature_flags"
- Enables feature toggle system
- Supports organization, branch, or user-level flags
- Polymorphic relationship for flexible assignment

Table "third_party_integrations" and "sync_logs"
- Manages external system integrations
- Tracks API credentials and status
- SyncLogs records synchronization history and status

Table "login_histories"
- Tracks user authentication events
- Stores IP and device information
- Supports security auditing

Table "versions"
- Implements papertrail/audit logging
- Tracks all changes to important tables
- Supports undo/rollback functionality


## Key Relationships
1.  **Organization Hierarchy**:
    -   Organizations have many Branches, Users, Vendors
    -   Branches have many Storages, Trucks

2.  **Order Flow**:
    -   DeliveryOrders belong to Branches (delivery location) and Vendors (distributor)
    -   DeliveryOrders have many OrderItems (products) and OrderChats (communication)

3.  **Resource Management**:
    -   Storages have many Products through StorageProducts (inventory)
    -   Products can be in many Storages

4.  **User System**:
    -   Users have many Roles through UserRoles
    -   Users have many LoginHistories

## Indexing Strategy

1.  **Primary Keys**: All tables have standard  `id`  primary keys
2.  **Foreign Keys**: All foreign keys are indexed for join performance

3.  **Unique Constraints**:
    -   Users.email (unique)
    -   DeliveryOrders.order_number (unique)

4.  **Composite Indexes**: Used for polymorphic relationships (documentable, flaggable)

## Performance Considerations
1.  **Read Optimization**:
    -   Frequent queries (order lookup, user auth) are heavily indexed

2.  **Caching Strategy**:
    -   User roles and permissions are cacheable
    -   Product catalog is cacheable
    -   Organization/vendor relationships are cacheable

## Security Implementation
1.  **Authentication**:
    -   Password hashing via password_digest
    -   Account lockout via failed_login_attempts and locked_at

2.  **Authorization**:
    -   RBAC through Roles and UserRoles
    -   Organization-scoped data access

3.  **Auditing**:
    -   Comprehensive login history
    -   Full version tracking of changes
    -   Document upload tracking
