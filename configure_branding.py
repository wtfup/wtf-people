import frappe
import os

os.chdir("/home/frappe/frappe-bench")
frappe.init(site="hrms.localhost", sites_path="/home/frappe/frappe-bench/sites")
frappe.connect()

# Set Navbar Settings
frappe.db.set_value("Navbar Settings", "Navbar Settings", "app_logo", "/files/wtf-logo.png")
print("Navbar logo set to /files/wtf-logo.png")

# Set Website Settings
frappe.db.set_value("Website Settings", "Website Settings", "app_name", "WTF People")
frappe.db.set_value("Website Settings", "Website Settings", "app_logo", "/files/wtf-logo.png")
print("Website Settings updated: app_name=WTF People, app_logo=/files/wtf-logo.png")

frappe.db.commit()
print("Branding configuration complete!")
