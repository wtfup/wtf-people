SET SQL_SAFE_UPDATES = 0;

-- Update the root cost center to match new company name
UPDATE `tabCost Center` SET
    company='Witness The Fitness Pvt Ltd',
    name='Witness The Fitness Pvt Ltd - WTF',
    cost_center_name='Witness The Fitness Pvt Ltd'
WHERE name='WTF - WTF';

-- Update Main cost center's parent and company
UPDATE `tabCost Center` SET
    company='Witness The Fitness Pvt Ltd',
    parent_cost_center='Witness The Fitness Pvt Ltd - WTF'
WHERE name='Main - WTF';

-- Verify
SELECT name, cost_center_name, parent_cost_center, company FROM `tabCost Center` WHERE company='Witness The Fitness Pvt Ltd';

SET SQL_SAFE_UPDATES = 1;
