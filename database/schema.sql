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
    UserID              INTEGER      NOT NULL,          
    GateID              INTEGER      NOT NULL,          
    Scanned_Barcode     VARCHAR(32)  NOT NULL,          
    Entry_Date          TEXT         NOT NULL,          
    Entry_Time          TEXT         NOT NULL,          
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
