INSERT INTO "USER" (UserID, Barcode, User_Name, User_Course, User_Status, Delete_At) VALUES
    (1, 'UG-2026-0001', 'Maria Santos',   'BS Information Technology', 'Active',    NULL),
    (2, 'UG-2026-0002', 'Juan Dela Cruz', 'BS Computer Science',       'Active',    NULL),
    (3, 'UG-2026-0003', 'Ana Reyes',      'BS Criminology',            'Active',    NULL),
    (4, 'UG-2026-0004', 'Pedro Gomez',    'BS Accountancy',            'Suspended', NULL),
    (5, 'UG-2024-0099', 'Liza Navarro',   'BS Education',              'Inactive',  '2026-10-01 09:00:00');

INSERT INTO USER_CONTACT (ContactID, UserID, Contact_Number) VALUES
    (1, 1, '09171234567'),
    (2, 1, '09181234567'),
    (3, 2, '09221234567'),
    (4, 3, '09331234567'),
    (5, 4, '09441234567'),
    (6, 5, '09551234567');

INSERT INTO GATE_CHECKPOINT (GateID, Campus, Gate_Name, Gate_Status, Delete_At) VALUES
    (1, 'Main Campus',  'Main Gate',    'Open',        NULL),
    (2, 'Main Campus',  'East Gate',    'Open',        NULL),
    (3, 'North Campus', 'North Gate',   'Closed',      NULL),
    (4, 'Main Campus',  'Old Back Gate','Maintenance', '2026-08-15 17:00:00');

INSERT INTO ENTRY_LOG (Log_ID, UserID, GateID, Scanned_Barcode, Entry_Date, Entry_Time, Verification_Status) VALUES
    (1, 1, 1, 'UG-2026-0001', '2026-11-09', '07:05:12', 'Granted'),
    (2, 2, 1, 'UG-2026-0002', '2026-11-09', '07:11:40', 'Granted'),
    (3, 1, 2, 'UG-2026-0001', '2026-11-09', '12:02:18', 'Granted'),
    (4, 4, 1, 'UG-2026-0004', '2026-11-09', '07:20:03', 'Denied'),
    (5, 3, 2, 'UG-2026-0099', '2026-11-09', '08:44:55', 'Mismatch'),
    (6, 2, 3, 'UG-2026-0002', '2026-11-09', '18:10:27', 'Denied'),
    (7, 3, 1, 'UG-2026-0003', '2026-11-08', '07:30:00', 'Granted');

INSERT INTO RECORD (RecordID, UserID, Log_ID, Entry_Date, Entry_Time, Record_Status) VALUES
    (1, 1, 1, '2026-11-09', '07:05:12', 'Recorded'),
    (2, 2, 2, '2026-11-09', '07:11:40', 'Recorded'),
    (3, 1, 3, '2026-11-09', '12:02:18', 'Recorded'),
    (4, 4, 4, '2026-11-09', '07:20:03', 'Flagged'),
    (5, 3, 5, '2026-11-09', '08:44:55', 'Flagged'),
    (6, 2, 6, '2026-11-09', '18:10:27', 'Flagged'),
    (7, 3, 7, '2026-11-08', '07:30:00', 'Recorded');
