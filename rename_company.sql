-- Rename existing WTF company to proper name
UPDATE tabCompany SET company_name='Witness The Fitness Pvt Ltd', name='Witness The Fitness Pvt Ltd' WHERE abbr='WTF' AND name='WTF';

-- Update all related records that reference the old company name
UPDATE `tabCost Center` SET company='Witness The Fitness Pvt Ltd', name=REPLACE(name, ' - WTF', ' - WTF') WHERE company='WTF';
UPDATE `tabCost Center` SET parent_cost_center='Witness The Fitness Pvt Ltd - WTF' WHERE parent_cost_center='WTF - WTF';
UPDATE tabDepartment SET company='Witness The Fitness Pvt Ltd' WHERE company='WTF';

-- Delete the Demo company if exists
DELETE FROM tabCompany WHERE name='WTF (Demo)';

-- Verify
SELECT name, abbr, company_name FROM tabCompany;
