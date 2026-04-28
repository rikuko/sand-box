-- Production Control System - PostgreSQL Database Schema
-- Created: 2026-04-28
-- Purpose: Complete database design for manufacturing production control system

-- ============================================================================
-- 1. USER MANAGEMENT TABLES
-- ============================================================================

-- Roles table
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- User-Role association (Many-to-Many)
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, role_id)
);

-- Permissions table
CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Role-Permission association (Many-to-Many)
CREATE TABLE role_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(role_id, permission_id)
);

-- ============================================================================
-- 2. PRODUCTS AND RECIPES TABLES
-- ============================================================================

-- Products table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    sku VARCHAR(100) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Recipes table (with versioning support)
CREATE TABLE recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    ingredients JSONB, -- Array of ingredient objects: [{name, quantity, unit}, ...]
    steps JSONB, -- Array of step objects: [{sequence, description, time_minutes}, ...]
    estimated_time_minutes INTEGER,
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 3. WORK INSTRUCTIONS TABLES
-- ============================================================================

-- Work Instructions table
CREATE TABLE work_instructions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    sequence_order INTEGER NOT NULL,
    estimated_time_minutes INTEGER,
    safety_notes TEXT,
    images JSONB, -- Array of image URLs: ["url1", "url2", ...]
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 4. WORKSTATION AND SHIFT TABLES
-- ============================================================================

-- Workstations table
CREATE TABLE workstations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    workstation_type VARCHAR(100), -- assembly, packaging, quality_check, etc.
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Production Plans table
CREATE TABLE production_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    recipe_id UUID NOT NULL REFERENCES recipes(id),
    workstation_id UUID NOT NULL REFERENCES workstations(id),
    planned_start TIMESTAMP NOT NULL,
    planned_end TIMESTAMP NOT NULL,
    planned_quantity INTEGER NOT NULL,
    status VARCHAR(50) DEFAULT 'planned', -- planned, in_progress, completed, cancelled
    priority INTEGER DEFAULT 5, -- 1-10, where 1 is highest
    notes TEXT,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shifts table
CREATE TABLE shifts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workstation_id UUID NOT NULL REFERENCES workstations(id),
    user_id UUID NOT NULL REFERENCES users(id),
    production_plan_id UUID REFERENCES production_plans(id),
    shift_start TIMESTAMP NOT NULL,
    shift_end TIMESTAMP,
    status VARCHAR(50) DEFAULT 'active', -- active, paused, completed
    produced_quantity INTEGER DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 5. SCRAP REPORTING TABLES
-- ============================================================================

-- Scrap Reports table
CREATE TABLE scrap_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shift_id UUID NOT NULL REFERENCES shifts(id),
    production_plan_id UUID NOT NULL REFERENCES production_plans(id),
    workstation_id UUID NOT NULL REFERENCES workstations(id),
    reported_by UUID NOT NULL REFERENCES users(id),
    product_id UUID NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL,
    reason VARCHAR(100) NOT NULL, -- material_defect, operator_error, equipment_failure, quality_issue, other
    description TEXT,
    status VARCHAR(50) DEFAULT 'reported', -- reported, approved, rejected
    approved_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 6. AUDIT AND LOGGING TABLES
-- ============================================================================

-- Audit Logs table (for tracking all changes)
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(50) NOT NULL, -- create, read, update, delete
    table_name VARCHAR(100) NOT NULL,
    record_id UUID,
    changes JSONB, -- Before and after values
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 7. INDEXES FOR PERFORMANCE
-- ============================================================================

-- User-related indexes
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);
CREATE INDEX idx_role_permissions_role_id ON role_permissions(role_id);

-- Product-related indexes
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_is_active ON products(is_active);
CREATE INDEX idx_recipes_product_id ON recipes(product_id);
CREATE INDEX idx_recipes_is_active ON recipes(is_active);
CREATE INDEX idx_recipes_created_by ON recipes(created_by);

-- Instruction-related indexes
CREATE INDEX idx_instructions_recipe_id ON work_instructions(recipe_id);
CREATE INDEX idx_instructions_is_active ON work_instructions(is_active);
CREATE INDEX idx_instructions_created_by ON work_instructions(created_by);

-- Workstation and Shift indexes
CREATE INDEX idx_workstations_is_active ON workstations(is_active);
CREATE INDEX idx_production_plans_workstation_id ON production_plans(workstation_id);
CREATE INDEX idx_production_plans_status ON production_plans(status);
CREATE INDEX idx_production_plans_planned_start ON production_plans(planned_start);
CREATE INDEX idx_shifts_workstation_id ON shifts(workstation_id);
CREATE INDEX idx_shifts_user_id ON shifts(user_id);
CREATE INDEX idx_shifts_status ON shifts(status);
CREATE INDEX idx_shifts_shift_start ON shifts(shift_start);

-- Scrap-related indexes
CREATE INDEX idx_scrap_reports_shift_id ON scrap_reports(shift_id);
CREATE INDEX idx_scrap_reports_workstation_id ON scrap_reports(workstation_id);
CREATE INDEX idx_scrap_reports_status ON scrap_reports(status);
CREATE INDEX idx_scrap_reports_created_at ON scrap_reports(created_at);
CREATE INDEX idx_scrap_reports_reported_by ON scrap_reports(reported_by);

-- Audit log indexes
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_table_name ON audit_logs(table_name);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- ============================================================================
-- 8. USEFUL VIEWS
-- ============================================================================

-- View: User with all roles and permissions
CREATE VIEW user_permissions AS
SELECT DISTINCT
    u.id AS user_id,
    u.username,
    r.id AS role_id,
    r.name AS role_name,
    p.id AS permission_id,
    p.name AS permission_name
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
LEFT JOIN role_permissions rp ON r.id = rp.role_id
LEFT JOIN permissions p ON rp.permission_id = p.id
WHERE u.is_active = true;

-- View: Active production plans with details
CREATE VIEW active_production_plans AS
SELECT
    pp.id,
    pp.product_id,
    p.name AS product_name,
    pp.recipe_id,
    r.name AS recipe_name,
    pp.workstation_id,
    w.name AS workstation_name,
    pp.planned_start,
    pp.planned_end,
    pp.planned_quantity,
    pp.status,
    pp.priority,
    pp.created_at
FROM production_plans pp
JOIN products p ON pp.product_id = p.id
JOIN recipes r ON pp.recipe_id = r.id
JOIN workstations w ON pp.workstation_id = w.id
WHERE pp.status IN ('planned', 'in_progress')
ORDER BY pp.priority ASC, pp.planned_start ASC;

-- View: Current active shifts
CREATE VIEW current_shifts AS
SELECT
    s.id,
    s.workstation_id,
    w.name AS workstation_name,
    s.user_id,
    u.username,
    u.first_name,
    u.last_name,
    s.production_plan_id,
    p.name AS product_name,
    s.shift_start,
    s.status,
    s.produced_quantity,
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - s.shift_start)) / 3600 AS hours_elapsed
FROM shifts s
JOIN workstations w ON s.workstation_id = w.id
JOIN users u ON s.user_id = u.id
LEFT JOIN production_plans pp ON s.production_plan_id = pp.id
LEFT JOIN products p ON pp.product_id = p.id
WHERE s.status = 'active'
ORDER BY s.shift_start DESC;

-- ============================================================================
-- 9. INITIAL DATA - ROLES
-- ============================================================================

INSERT INTO roles (name, description) VALUES
    ('operator', 'Basic operator user - can view plans and report scrap'),
    ('supervisor', 'Supervisor - can approve reports and view analytics'),
    ('manager', 'Production Manager - can manage recipes and instructions'),
    ('admin', 'System Administrator - full system access');

-- ============================================================================
-- 10. INITIAL DATA - PERMISSIONS
-- ============================================================================

INSERT INTO permissions (name, description) VALUES
    -- User permissions
    ('view_users', 'View list of users'),
    ('create_user', 'Create new user'),
    ('edit_user', 'Edit user information'),
    ('delete_user', 'Delete user'),
    ('assign_roles', 'Assign roles to users'),
    
    -- Production plan permissions
    ('view_production_plans', 'View production plans'),
    ('create_production_plan', 'Create new production plan'),
    ('edit_production_plan', 'Edit production plans'),
    ('delete_production_plan', 'Delete production plans'),
    
    -- Recipe permissions
    ('view_recipes', 'View recipes'),
    ('create_recipe', 'Create new recipe'),
    ('edit_recipe', 'Edit recipes'),
    ('delete_recipe', 'Delete recipes'),
    
    -- Instruction permissions
    ('view_instructions', 'View work instructions'),
    ('create_instruction', 'Create new instruction'),
    ('edit_instruction', 'Edit instructions'),
    ('delete_instruction', 'Delete instructions'),
    
    -- Workstation permissions
    ('view_workstations', 'View workstations'),
    ('login_workstation', 'Login to workstation'),
    ('logout_workstation', 'Logout from workstation'),
    
    -- Shift permissions
    ('view_shifts', 'View shifts'),
    ('end_shift', 'End shift'),
    ('pause_shift', 'Pause shift'),
    ('resume_shift', 'Resume shift'),
    
    -- Scrap permissions
    ('report_scrap', 'Report scrap pieces'),
    ('view_scrap_reports', 'View scrap reports'),
    ('approve_scrap', 'Approve scrap reports'),
    ('edit_scrap_report', 'Edit scrap reports'),
    
    -- Audit permissions
    ('view_audit_logs', 'View audit logs'),
    ('view_analytics', 'View analytics and reports');

-- ============================================================================
-- 11. ASSIGN PERMISSIONS TO ROLES
-- ============================================================================

-- Operator role permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'operator' AND p.name IN (
    'view_production_plans', 'view_recipes', 'view_instructions',
    'view_workstations', 'login_workstation', 'logout_workstation',
    'report_scrap', 'view_shifts', 'end_shift'
);

-- Supervisor role permissions (includes all operator permissions)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'supervisor' AND p.name IN (
    'view_production_plans', 'view_recipes', 'view_instructions',
    'view_workstations', 'login_workstation', 'logout_workstation',
    'report_scrap', 'view_shifts', 'end_shift',
    'approve_scrap', 'view_scrap_reports', 'view_audit_logs',
    'view_analytics', 'view_users'
);

-- Manager role permissions (includes all supervisor permissions)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'manager' AND p.name IN (
    'view_production_plans', 'create_production_plan', 'edit_production_plan',
    'view_recipes', 'create_recipe', 'edit_recipe',
    'view_instructions', 'create_instruction', 'edit_instruction',
    'view_workstations', 'login_workstation', 'logout_workstation',
    'report_scrap', 'view_shifts', 'end_shift',
    'approve_scrap', 'view_scrap_reports', 'view_audit_logs',
    'view_analytics', 'view_users'
);

-- Admin role permissions (all permissions)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'admin';
