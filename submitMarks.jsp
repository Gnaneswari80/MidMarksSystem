<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page session="true" %>

<%
    request.setCharacterEncoding("UTF-8");

    // Get session attributes or request parameters for context info
    String batchYear = (String) session.getAttribute("batchYear");
    String subjectId = (String) session.getAttribute("subjectId");
    String department = (String) session.getAttribute("department");
    String sem = (String) session.getAttribute("sem");
    String year = (String) session.getAttribute("year");
    String mid = (String) session.getAttribute("mid");

    if (batchYear == null || subjectId == null || department == null || sem == null || year == null || mid == null) {
        out.println("<p style='color:red;'>Session expired or missing details. Please login and select again.</p>");
        return;
    }

    // Parse max marks from form
    int max_1a = Integer.parseInt(request.getParameter("max_1a"));
    int max_1b = Integer.parseInt(request.getParameter("max_1b"));
    int max_2a = Integer.parseInt(request.getParameter("max_2a"));
    int max_2b = Integer.parseInt(request.getParameter("max_2b"));
    int max_3a = Integer.parseInt(request.getParameter("max_3a"));
    int max_3b = Integer.parseInt(request.getParameter("max_3b"));
    int max_4a = Integer.parseInt(request.getParameter("max_4a"));
    int max_4b = Integer.parseInt(request.getParameter("max_4b"));
    int max_5a = Integer.parseInt(request.getParameter("max_5a"));
    int max_5b = Integer.parseInt(request.getParameter("max_5b"));
    int max_6a = Integer.parseInt(request.getParameter("max_6a"));
    int max_6b = Integer.parseInt(request.getParameter("max_6b"));
    int max_ass = Integer.parseInt(request.getParameter("max_ass"));

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/midmarks_db", "root", "");

        // 1) Upsert questionmaxmarks record
        String checkMaxSql = "SELECT COUNT(*) FROM questionmaxmarks WHERE qmmBatchyear = ? AND qmmSubjectId = ? AND qmmMid = ? AND qmmSem = ? AND qmmYear = ?";
        PreparedStatement psCheckMax = con.prepareStatement(checkMaxSql);
        psCheckMax.setString(1, batchYear);
        psCheckMax.setString(2, subjectId);
        psCheckMax.setString(3, mid);
        psCheckMax.setString(4, sem);
        psCheckMax.setString(5, year);
        ResultSet rsCheck = psCheckMax.executeQuery();
        rsCheck.next();
        int count = rsCheck.getInt(1);
        rsCheck.close();
        psCheckMax.close();

        if (count > 0) {
            // Update existing max marks
            String updateMaxSql = "UPDATE questionmaxmarks SET max_1a=?, max_1b=?, max_2a=?, max_2b=?, max_3a=?, max_3b=?, max_4a=?, max_4b=?, max_5a=?, max_5b=?, max_6a=?, max_6b=?, qmmass=? WHERE qmmBatchyear=? AND qmmSubjectId=? AND qmmMid=? AND qmmSem=? AND qmmYear=?";
            PreparedStatement psUpdateMax = con.prepareStatement(updateMaxSql);
            psUpdateMax.setInt(1, max_1a);
            psUpdateMax.setInt(2, max_1b);
            psUpdateMax.setInt(3, max_2a);
            psUpdateMax.setInt(4, max_2b);
            psUpdateMax.setInt(5, max_3a);
            psUpdateMax.setInt(6, max_3b);
            psUpdateMax.setInt(7, max_4a);
            psUpdateMax.setInt(8, max_4b);
            psUpdateMax.setInt(9, max_5a);
            psUpdateMax.setInt(10, max_5b);
            psUpdateMax.setInt(11, max_6a);
            psUpdateMax.setInt(12, max_6b);
            psUpdateMax.setInt(13, max_ass);
            psUpdateMax.setString(14, batchYear);
            psUpdateMax.setString(15, subjectId);
            psUpdateMax.setString(16, mid);
            psUpdateMax.setString(17, sem);
            psUpdateMax.setString(18, year);
            psUpdateMax.executeUpdate();
            psUpdateMax.close();
        } else {
            // Insert new max marks
            String insertMaxSql = "INSERT INTO questionmaxmarks (qmmBatchyear, qmmSubjectId, qmmMid, qmmSem, qmmYear, max_1a, max_1b, max_2a, max_2b, max_3a, max_3b, max_4a, max_4b, max_5a, max_5b, max_6a, max_6b, qmmass) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement psInsertMax = con.prepareStatement(insertMaxSql);
            psInsertMax.setString(1, batchYear);
            psInsertMax.setString(2, subjectId);
            psInsertMax.setString(3, mid);
            psInsertMax.setString(4, sem);
            psInsertMax.setString(5, year);
            psInsertMax.setInt(6, max_1a);
            psInsertMax.setInt(7, max_1b);
            psInsertMax.setInt(8, max_2a);
            psInsertMax.setInt(9, max_2b);
            psInsertMax.setInt(10, max_3a);
            psInsertMax.setInt(11, max_3b);
            psInsertMax.setInt(12, max_4a);
            psInsertMax.setInt(13, max_4b);
            psInsertMax.setInt(14, max_5a);
            psInsertMax.setInt(15, max_5b);
            psInsertMax.setInt(16, max_6a);
            psInsertMax.setInt(17, max_6b);
            psInsertMax.setInt(18, max_ass);
            psInsertMax.executeUpdate();
            psInsertMax.close();
        }

        // 2) Update/Insert each student's marks
        Enumeration<String> paramNames = request.getParameterNames();
        Set<String> studentIds = new HashSet<>();

        // Collect all student IDs from form inputs
        while(paramNames.hasMoreElements()){
            String param = paramNames.nextElement();
            if(param.contains("_")){
                String[] parts = param.split("_");
                if(parts.length == 3){
                    studentIds.add(parts[2]);
                }
            }
        }

        for(String sid : studentIds){
            // Parse marks for student sid
            int m_1a = Integer.parseInt(request.getParameter("marks_1a_" + sid));
            int m_1b = Integer.parseInt(request.getParameter("marks_1b_" + sid));
            int m_2a = Integer.parseInt(request.getParameter("marks_2a_" + sid));
            int m_2b = Integer.parseInt(request.getParameter("marks_2b_" + sid));
            int m_3a = Integer.parseInt(request.getParameter("marks_3a_" + sid));
            int m_3b = Integer.parseInt(request.getParameter("marks_3b_" + sid));
            int m_4a = Integer.parseInt(request.getParameter("marks_4a_" + sid));
            int m_4b = Integer.parseInt(request.getParameter("marks_4b_" + sid));
            int m_5a = Integer.parseInt(request.getParameter("marks_5a_" + sid));
            int m_5b = Integer.parseInt(request.getParameter("marks_5b_" + sid));
            int m_6a = Integer.parseInt(request.getParameter("marks_6a_" + sid));
            int m_6b = Integer.parseInt(request.getParameter("marks_6b_" + sid));
            int ass = Integer.parseInt(request.getParameter("ass_" + sid));
            int midmark = 0;
            try {
                midmark = Integer.parseInt(request.getParameter("midmark_" + sid));
            } catch(Exception e) {
                midmark = 0;
            }

            // Check if record exists
            String checkMarkSql = "SELECT COUNT(*) FROM studentmidmarks WHERE sid = ? AND sub_id = ? AND smmMid = ? AND student_sem = ? AND student_year = ? AND sbatch_year = ? AND smmdepartment = ?";
            PreparedStatement psCheckMark = con.prepareStatement(checkMarkSql);
            psCheckMark.setString(1, sid);
            psCheckMark.setString(2, subjectId);
            psCheckMark.setString(3, mid);
            psCheckMark.setString(4, sem);
            psCheckMark.setString(5, year);
            psCheckMark.setString(6, batchYear);
            psCheckMark.setString(7, department);
            ResultSet rsCheckMark = psCheckMark.executeQuery();
            rsCheckMark.next();
            int exists = rsCheckMark.getInt(1);
            rsCheckMark.close();
            psCheckMark.close();

            if(exists > 0){
                // Update existing
                String updateMarksSql = "UPDATE studentmidmarks SET marks_1a=?, marks_1b=?, marks_2a=?, marks_2b=?, marks_3a=?, marks_3b=?, marks_4a=?, marks_4b=?, marks_5a=?, marks_5b=?, marks_6a=?, marks_6b=?, ass=?, midmark=? WHERE sid=? AND sub_id=? AND smmMid=? AND student_sem=? AND student_year=? AND sbatch_year=? AND smmdepartment=?";
                PreparedStatement psUpdateMarks = con.prepareStatement(updateMarksSql);
                psUpdateMarks.setInt(1, m_1a);
                psUpdateMarks.setInt(2, m_1b);
                psUpdateMarks.setInt(3, m_2a);
                psUpdateMarks.setInt(4, m_2b);
                psUpdateMarks.setInt(5, m_3a);
                psUpdateMarks.setInt(6, m_3b);
                psUpdateMarks.setInt(7, m_4a);
                psUpdateMarks.setInt(8, m_4b);
                psUpdateMarks.setInt(9, m_5a);
                psUpdateMarks.setInt(10, m_5b);
                psUpdateMarks.setInt(11, m_6a);
                psUpdateMarks.setInt(12, m_6b);
                psUpdateMarks.setInt(13, ass);
                psUpdateMarks.setInt(14, midmark);
                psUpdateMarks.setString(15, sid);
                psUpdateMarks.setString(16, subjectId);
                psUpdateMarks.setString(17, mid);
                psUpdateMarks.setString(18, sem);
                psUpdateMarks.setString(19, year);
                psUpdateMarks.setString(20, batchYear);
                psUpdateMarks.setString(21, department);
                psUpdateMarks.executeUpdate();
                psUpdateMarks.close();
            } else {
                // Insert new record
                // Get student name from studentdetails
                String studentName = "";
                PreparedStatement psGetName = con.prepareStatement("SELECT student_name FROM studentdetails WHERE student_id = ?");
                psGetName.setString(1, sid);
                ResultSet rsName = psGetName.executeQuery();
                if(rsName.next()) {
                    studentName = rsName.getString("student_name");
                }
                rsName.close();
                psGetName.close();

                String insertMarksSql = "INSERT INTO studentmidmarks (sid, sname, sub_id, student_sem, student_year, sbatch_year, smmdepartment, smmMid, marks_1a, marks_1b, marks_2a, marks_2b, marks_3a, marks_3b, marks_4a, marks_4b, marks_5a, marks_5b, marks_6a, marks_6b, ass, midmark) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement psInsertMarks = con.prepareStatement(insertMarksSql);
                psInsertMarks.setString(1, sid);
                psInsertMarks.setString(2, studentName);
                psInsertMarks.setString(3, subjectId);
                psInsertMarks.setString(4, sem);
                psInsertMarks.setString(5, year);
                psInsertMarks.setString(6, batchYear);
                psInsertMarks.setString(7, department);
                psInsertMarks.setString(8, mid);
                psInsertMarks.setInt(9, m_1a);
                psInsertMarks.setInt(10, m_1b);
                psInsertMarks.setInt(11, m_2a);
                psInsertMarks.setInt(12, m_2b);
                psInsertMarks.setInt(13, m_3a);
                psInsertMarks.setInt(14, m_3b);
                psInsertMarks.setInt(15, m_4a);
                psInsertMarks.setInt(16, m_4b);
                psInsertMarks.setInt(17, m_5a);
                psInsertMarks.setInt(18, m_5b);
                psInsertMarks.setInt(19, m_6a);
                psInsertMarks.setInt(20, m_6b);
                psInsertMarks.setInt(21, ass);
                psInsertMarks.setInt(22, midmark);
                psInsertMarks.executeUpdate();
                psInsertMarks.close();
            }
        }

        con.close();

        out.println("<p style='color:green;'>Marks and max marks saved successfully!</p>");
        out.println("<p><a href='enterMarks.jsp'>Go back to enter marks</a></p>");

    } catch(Exception e){
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
       
    }
%>