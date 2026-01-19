UPDATE tabSingles SET value='/files/wtf-logo.png' WHERE doctype='Navbar Settings' AND field='app_logo';
UPDATE tabSingles SET value='/files/wtf-logo.png' WHERE doctype='Website Settings' AND field='app_logo';
UPDATE tabSingles SET value='WTF People' WHERE doctype='Website Settings' AND field='app_name';
SELECT doctype, field, value FROM tabSingles WHERE doctype IN ('Navbar Settings', 'Website Settings') AND field IN ('app_logo', 'app_name');
