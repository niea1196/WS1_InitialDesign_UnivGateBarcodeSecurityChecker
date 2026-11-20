-- University Gate Barcode Security Checker System

CREATE TABLE "USER" (
    UserID       INTEGER      PRIMARY KEY,
    Barcode      VARCHAR(32)  NOT NULL UNIQUE,          
    User_Name    VARCHAR(120) NOT NULL,
    User_Course  VARCHAR(120) NOT NULL,
    User_Status  VARCHAR(20)  NOT NULL DEFAULT 'Active'
                 CHECK (User_Status IN ('Active', 'Inactive', 'Suspended')),
    Delete_At    TEXT         NULL                      
);

CREATE TABLE USER_CONTACT (
    ContactID      INTEGER      PRIMARY KEY,
    UserID         INTEGER      NOT NULL,
    Contact_Number VARCHAR(20)  NOT NULL,
    UNIQUE (UserID, Contact_Number),
    FOREIGN KEY (UserID) REFERENCES "USER" (UserID)
);

CREATE TABLE GATE_CHECKPOINT (
    GateID      INTEGER      PRIMARY KEY,
    Campus      VARCHAR(80)  NOT NULL,
    Gate_Name   VARCHAR(80)  NOT NULL,
    Gate_Status VARCHAR(20)  NOT NULL DEFAULT 'Open'
                CHECK (Gate_Status IN ('Open', 'Closed', 'Maintenance')),
    Delete_At   TEXT         NULL,
    UNIQUE (Campus, Gate_Name)
);

CREATE TABLE ENTRY_LOG (
    Log_ID              INTEGER      PRIMARY KEY,
    UserID              INTEGER      NOT NULL,          -- FK, the user who scans
    GateID              INTEGER      NOT NULL,          -- FK, the gate that records it
    Scanned_Barcode     VARCHAR(32)  NOT NULL,          -- value read at the gate
    Entry_Date          TEXT         NOT NULL,          -- ISO date YYYY-MM-DD
    Entry_Time          TEXT         NOT NULL,          -- HH:MM:SS
    Verification_Status VARCHAR(20)  NOT NULL
                        CHECK (Verification_Status IN ('Granted', 'Denied', 'Mismatch')),
    FOREIGN KEY (UserID) REFERENCES "USER" (UserID),
    FOREIGN KEY (GateID) REFERENCES GATE_CHECKPOINT (GateID)
);

CREATE TABLE RECORD (
    RecordID     INTEGER      PRIMARY KEY,
    UserID       INTEGER      NOT NULL,
    Log_ID       INTEGER      NOT NULL UNIQUE,
    Entry_Date   TEXT         NOT NULL,
    Entry_Time   TEXT         NOT NULL,
    Record_Status VARCHAR(20) NOT NULL DEFAULT 'Recorded'
                 CHECK (Record_Status IN ('Recorded', 'Flagged', 'Void')),
    FOREIGN KEY (UserID) REFERENCES "USER" (UserID),
    FOREIGN KEY (Log_ID) REFERENCES ENTRY_LOG (Log_ID)
);

CREATE TRIGGER trg_record_matches_log
BEFORE INSERT ON RECORD
FOR EACH ROW
WHEN (
    SELECT UserID || '|' || Entry_Date || '|' || Entry_Time
    FROM ENTRY_LOG
    WHERE Log_ID = NEW.Log_ID
) IS NOT (
    NEW.UserID || '|' || NEW.Entry_Date || '|' || NEW.Entry_Time
)
BEGIN
    SELECT RAISE(ABORT, 'RECORD snapshot must match UserID, Entry_Date, and Entry_Time of its ENTRY_LOG');
END;

CREATE INDEX idx_entry_log_user ON ENTRY_LOG (UserID);
CREATE INDEX idx_entry_log_gate ON ENTRY_LOG (GateID);
CREATE INDEX idx_entry_log_when ON ENTRY_LOG (Entry_Date, Entry_Time);
CREATE INDEX idx_entry_log_status ON ENTRY_LOG (Verification_Status);
CREATE INDEX idx_record_user ON RECORD (UserID);
CREATE INDEX idx_user_contact_user ON USER_CONTACT (UserID);

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
