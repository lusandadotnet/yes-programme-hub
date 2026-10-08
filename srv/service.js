const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {
    const { Youth, MonthlyLog } = this.entities;

    // parse dob from SA ID (YYMMDD format)
    function parseSAIdBirthDate(idNumber) {
        if (!idNumber || idNumber.length < 6) return null;
        
        const yy = parseInt(idNumber.substring(0, 2), 10);
        const mm = parseInt(idNumber.substring(2, 4), 10) - 1;
        const dd = parseInt(idNumber.substring(4, 6), 10);

        // standard South African age assumption based on current century
        const currentYear = new Date().getFullYear();
        const currentCentury = Math.floor(currentYear / 100) * 100;
        const fullYear = (yy <= currentYear % 100) ? (currentCentury + yy) : (currentCentury - 100 + yy);

        return new Date(fullYear, mm, dd);
    }

    // calculate age at a given date
    function calculateAge(birthDate, referenceDate) {
        let age = referenceDate.getFullYear() - birthDate.getFullYear();
        const monthDiff = referenceDate.getMonth() - birthDate.getMonth();
        if (monthDiff < 0 || (monthDiff === 0 && referenceDate.getDate() < birthDate.getDate())) {
            age--;
        }
        return age;
    }

    // age eligibility validator (18–35 years)
    this.before('CREATE', 'Youth', (req) => {
        const { IDNumber, StartDate } = req.data;
        if (!IDNumber) return;

        const birthDate = parseSAIdBirthDate(IDNumber);
        if (!birthDate || isNaN(birthDate.getTime())) {
            return req.reject(400, 'Invalid South African ID Number format.');
        }

        const effectiveDate = StartDate ? new Date(StartDate) : new Date();
        const age = calculateAge(birthDate, effectiveDate);

        if (age < 18 || age > 35) {
            req.reject(400, `Participant must be between 18 and 35 years old at start date. Calculated age: ${age}.`);
        }

        // eish set 365-day end date automatically if startdate is provided
        if (StartDate) {
            const start = new Date(StartDate);
            start.setDate(start.getDate() + 365);
            req.data.EndDate = start.toISOString().split('T')[0];
        }
    });

    // auto-calculate 365-day end date
    this.before('UPDATE', 'Youth', (req) => {
        if (req.data.StartDate) {
            const start = new Date(req.data.StartDate);
            start.setDate(start.getDate() + 365);
            req.data.EndDate = start.toISOString().split('T')[0];
        }
    });

    // virtual field for high hisk attendance (over 80% for 2 consecutive months)
    this.after('READ', 'Youth', async (results, req) => {
        if (!results) return;
        const youths = Array.isArray(results) ? results : [results];

        for (const youth of youths) {
            if (!youth.ID) continue;

            const logs = await SELECT.from(MonthlyLog)
                .where({ youth_ID: youth.ID })
                .orderBy('MonthNumber asc');

            let consecutiveLowAttendance = 0;
            let isHighRisk = false;

            for (const log of logs) {
                if (log.Attendance !== null && Number(log.Attendance) < 80.0) {
                    consecutiveLowAttendance++;
                    if (consecutiveLowAttendance >= 2) {
                        isHighRisk = true;
                        break;
                    }
                } else {
                    consecutiveLowAttendance = 0;
                }
            }

            youth.isHighRisk = isHighRisk;
        }
    });
});