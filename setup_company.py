#!/usr/bin/env python
"""
Setup script for WTF People HRMS
Creates Cost Centers, Departments, Designations, Grades
"""
import os
import sys

# Add frappe to path
sys.path.insert(0, '/home/frappe/frappe-bench/apps/frappe')
sys.path.insert(0, '/home/frappe/frappe-bench/apps/erpnext')
sys.path.insert(0, '/home/frappe/frappe-bench/apps/hrms')

os.chdir('/home/frappe/frappe-bench')

import frappe
frappe.init(site='hrms.localhost', sites_path='/home/frappe/frappe-bench/sites')
frappe.connect()
frappe.set_user('Administrator')

COMPANY = "Witness The Fitness Pvt Ltd"
ABBR = "WTF"

print("=" * 50)
print("WTF People - HRMS Setup")
print("=" * 50)

# 1. Verify Company exists
print(f"\n1. Verifying Company: {COMPANY}")
if frappe.db.exists("Company", COMPANY):
    print(f"   Found: {COMPANY}")
else:
    print(f"   ERROR: Company {COMPANY} not found!")
    sys.exit(1)

# 2. Create Cost Centers (Brands)
print("\n2. Creating Cost Centers (Brands)...")
cost_centers = [
    {"cost_center_name": "WTF Gyms", "cost_center_number": "WTF-GYMS"},
    {"cost_center_name": "WTF Academy", "cost_center_number": "WTF-ACAD"},
    {"cost_center_name": "WTF Everyday", "cost_center_number": "WTF-EVRY"},
    {"cost_center_name": "WTF Reboot", "cost_center_number": "WTF-REBT"},
]

parent_cc = f"{COMPANY} - {ABBR}"
for cc in cost_centers:
    cc_name = f"{cc['cost_center_name']} - {ABBR}"
    if not frappe.db.exists("Cost Center", cc_name):
        try:
            cost_center = frappe.get_doc({
                "doctype": "Cost Center",
                "cost_center_name": cc["cost_center_name"],
                "cost_center_number": cc["cost_center_number"],
                "company": COMPANY,
                "parent_cost_center": parent_cc,
                "is_group": 0
            })
            cost_center.insert(ignore_permissions=True)
            print(f"   Created: {cc['cost_center_name']}")
        except Exception as e:
            print(f"   Error creating {cc['cost_center_name']}: {e}")
    else:
        print(f"   Already exists: {cc['cost_center_name']}")

frappe.db.commit()

# 3. Create Departments
print("\n3. Creating Departments...")
departments = [
    "Technology",
    "Marketing",
    "Finance & Accounts",
    "Human Resources",
    "Operations",
    "Business Development",
    "Design"
]

for dept_name in departments:
    dept_full = f"{dept_name} - {ABBR}"
    if not frappe.db.exists("Department", dept_full):
        try:
            dept = frappe.get_doc({
                "doctype": "Department",
                "department_name": dept_name,
                "company": COMPANY
            })
            dept.insert(ignore_permissions=True)
            print(f"   Created: {dept_name}")
        except Exception as e:
            print(f"   Error creating {dept_name}: {e}")
    else:
        print(f"   Already exists: {dept_name}")

frappe.db.commit()

# 4. Create Designations
print("\n4. Creating Designations...")
designations = [
    "Founder",
    "Co-Founder",
    "Chief Executive Officer",
    "Chief Product Officer",
    "Chief Operating Officer",
    "Vice President",
    "Director",
    "Senior Manager",
    "Manager",
    "Lead",
    "Senior Executive",
    "Executive",
    "Associate",
    "Intern"
]

for desig_name in designations:
    if not frappe.db.exists("Designation", desig_name):
        try:
            desig = frappe.get_doc({
                "doctype": "Designation",
                "designation_name": desig_name
            })
            desig.insert(ignore_permissions=True)
            print(f"   Created: {desig_name}")
        except Exception as e:
            print(f"   Error creating {desig_name}: {e}")
    else:
        print(f"   Already exists: {desig_name}")

frappe.db.commit()

# 5. Create Employee Grades
print("\n5. Creating Employee Grades...")
grades = [
    {"name": "L1 - Entry", "default_base_pay": 300000},
    {"name": "L2 - Junior", "default_base_pay": 500000},
    {"name": "L3 - Mid", "default_base_pay": 800000},
    {"name": "L4 - Senior", "default_base_pay": 1200000},
    {"name": "L5 - Leadership", "default_base_pay": 2000000},
    {"name": "L6 - Executive", "default_base_pay": 3600000},
]

for grade in grades:
    if not frappe.db.exists("Employee Grade", grade["name"]):
        try:
            grade_doc = frappe.get_doc({
                "doctype": "Employee Grade",
                "name": grade["name"],
                "default_base_pay": grade["default_base_pay"]
            })
            grade_doc.insert(ignore_permissions=True)
            print(f"   Created: {grade['name']}")
        except Exception as e:
            print(f"   Error creating {grade['name']}: {e}")
    else:
        print(f"   Already exists: {grade['name']}")

frappe.db.commit()

# 6. Add Custom Field "Serves All Brands" to Employee
print("\n6. Adding Custom Field 'Serves All Brands'...")
cf_name = "Employee-serves_all_brands"
if not frappe.db.exists("Custom Field", cf_name):
    try:
        custom_field = frappe.get_doc({
            "doctype": "Custom Field",
            "dt": "Employee",
            "fieldname": "serves_all_brands",
            "fieldtype": "Check",
            "label": "Serves All Brands",
            "description": "Check if this employee supports all brands (e.g., shared Marketing, HR, Finance)",
            "insert_after": "payroll_cost_center"
        })
        custom_field.insert(ignore_permissions=True)
        print("   Created: serves_all_brands field")
    except Exception as e:
        print(f"   Error creating custom field: {e}")
else:
    print("   Already exists: serves_all_brands field")

frappe.db.commit()

print("\n" + "=" * 50)
print("Setup Complete!")
print("=" * 50)
print(f"\nCompany: {COMPANY}")
print("Cost Centers: WTF Gyms, Academy, Everyday, Reboot")
print("Departments: Technology, Marketing, Finance, HR, Operations, BD, Design")
print("Designations: 14 levels from Intern to Founder")
print("Grades: L1 to L6")
print("Custom Field: serves_all_brands on Employee")
