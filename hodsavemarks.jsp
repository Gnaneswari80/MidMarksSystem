<%@ page import="java.sql.*, java.util.*" %> 
<%
String batchYear = request.getParameter("batchYear");
String sem = request.getParameter("sem");
String year = request.getParameter("year");
String department = request.getParameter("department");
String subjectId = request.getParameter("subjectId");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/midmarks_db","root","");
conn.setAutoCommit(false);

try {
    // Update max marks for mid1
    String updateMaxSql = "UPDATE questionmaxmarks SET max_1a=?, max_1b=?, max_2a=?, max_2b=?, max_3a=?, max_3b=?, max_4a=?, max_4b=?, max_5a=?, max_5b=?, max_6a=?, max_6b=?, qmmass=? WHERE qmmBatchyear=? AND qmmSubjectId=? AND qmmSem=? AND qmmYear=? AND qmmMid=?";
    PreparedStatement psMax = conn.prepareStatement(updateMaxSql);

    for (int i=0; i<=12; i++) {
        psMax.setInt(i+1, Integer.parseInt(request.getParameter("max1_" + i)));
    }
    psMax.setString(14, batchYear);
    psMax.setString(15, subjectId);
    psMax.setString(16, sem);
    psMax.setString(17, year);
    psMax.setString(18, "mid1");
    psMax.executeUpdate();

    // Update max marks for mid2
    for (int i=0; i<=12; i++) {
        psMax.setInt(i+1, Integer.parseInt(request.getParameter("max2_" + i)));
    }
    psMax.setString(14, batchYear);
    psMax.setString(15, subjectId);
    psMax.setString(16, sem);
    psMax.setString(17, year);
    psMax.setString(18, "mid2");
    psMax.executeUpdate();

    // Prepare statements for studentmidmarks
    String checkSql = "SELECT COUNT(*) FROM studentmidmarks WHERE sub_id=? AND student_sem=? AND student_year=? AND sbatch_year=? AND smmdepartment=? AND smmMid=? AND sid=?";
    PreparedStatement psCheck = conn.prepareStatement(checkSql);

    String updateSql = "UPDATE studentmidmarks SET marks_1a=?, marks_1b=?, marks_2a=?, marks_2b=?, marks_3a=?, marks_3b=?, marks_4a=?, marks_4b=?, marks_5a=?, marks_5b=?, marks_6a=?, marks_6b=?, ass=?, midmark=? WHERE sub_id=? AND student_sem=? AND student_year=? AND sbatch_year=? AND smmdepartment=? AND smmMid=? AND sid=?";
    PreparedStatement psUpdate = conn.prepareStatement(updateSql);

    String insertSql = "INSERT INTO studentmidmarks (sid, student_sem, student_year, sbatch_year, smmdepartment, sub_id, smmMid, marks_1a, marks_1b, marks_2a, marks_2b, marks_3a, marks_3b, marks_4a, marks_4b, marks_5a, marks_5b, marks_6a, marks_6b, ass, midmark) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    PreparedStatement psInsert = conn.prepareStatement(insertSql);

    // Maps to hold student marks: key = sid, value = int[13]
    Map<String, int[]> mid1MarksMap = new HashMap<>();
    Map<String, int[]> mid2MarksMap = new HashMap<>();

    // Parse parameters for mid1 and mid2 marks
    java.util.Enumeration<String> paramNames = request.getParameterNames();
    while (paramNames.hasMoreElements()) {
        String paramName = paramNames.nextElement();
        if (paramName.startsWith("mid1_")) {
            String[] parts = paramName.split("_");
            if (parts.length == 3) {
                String sid = parts[1];
                int idx = Integer.parseInt(parts[2]);
                int mark = 0;
                try {
                    mark = Integer.parseInt(request.getParameter(paramName));
                } catch(Exception e) { mark = 0; }
                int[] marks = mid1MarksMap.get(sid);
                if (marks == null) {
                    marks = new int[13];
                    mid1MarksMap.put(sid, marks);
                }
                marks[idx] = mark;
            }
        } else if (paramName.startsWith("mid2_")) {
            String[] parts = paramName.split("_");
            if (parts.length == 3) {
                String sid = parts[1];
                int idx = Integer.parseInt(parts[2]);
                int mark = 0;
                try {
                    mark = Integer.parseInt(request.getParameter(paramName));
                } catch(Exception e) { mark = 0; }
                int[] marks = mid2MarksMap.get(sid);
                if (marks == null) {
                    marks = new int[13];
                    mid2MarksMap.put(sid, marks);
                }
                marks[idx] = mark;
            }
        }
    }

    // Save mid1 marks
    for (String sid : mid1MarksMap.keySet()) {
        int[] marks = mid1MarksMap.get(sid);

        psCheck.setString(1, subjectId);
        psCheck.setString(2, sem);
        psCheck.setString(3, year);
        psCheck.setString(4, batchYear);
        psCheck.setString(5, department);
        psCheck.setString(6, "mid1");
        psCheck.setString(7, sid);
        ResultSet rs = psCheck.executeQuery();
        rs.next();
        int count = rs.getInt(1);
        rs.close();

        int ass = marks[12];
        int midmark = 0; // set if needed

        if(count > 0) {
            psUpdate.setInt(1, marks[0]);
            psUpdate.setInt(2, marks[1]);
            psUpdate.setInt(3, marks[2]);
            psUpdate.setInt(4, marks[3]);
            psUpdate.setInt(5, marks[4]);
            psUpdate.setInt(6, marks[5]);
            psUpdate.setInt(7, marks[6]);
            psUpdate.setInt(8, marks[7]);
            psUpdate.setInt(9, marks[8]);
            psUpdate.setInt(10, marks[9]);
            psUpdate.setInt(11, marks[10]);
            psUpdate.setInt(12, marks[11]);
            psUpdate.setInt(13, ass);
            psUpdate.setInt(14, midmark);
            psUpdate.setString(15, subjectId);
            psUpdate.setString(16, sem);
            psUpdate.setString(17, year);
            psUpdate.setString(18, batchYear);
            psUpdate.setString(19, department);
            psUpdate.setString(20, "mid1");
            psUpdate.setString(21, sid);
            psUpdate.executeUpdate();
        } else {
            psInsert.setString(1, sid);
            psInsert.setString(2, sem);
            psInsert.setString(3, year);
            psInsert.setString(4, batchYear);
            psInsert.setString(5, department);
            psInsert.setString(6, subjectId);
            psInsert.setString(7, "mid1");
            for(int i=0; i<12; i++) {
                psInsert.setInt(8+i, marks[i]);
            }
            psInsert.setInt(20, ass);
            psInsert.setInt(21, midmark);
            psInsert.executeUpdate();
        }
    }

    // Save mid2 marks (same logic)
    for (String sid : mid2MarksMap.keySet()) {
        int[] marks = mid2MarksMap.get(sid);

        psCheck.setString(1, subjectId);
        psCheck.setString(2, sem);
        psCheck.setString(3, year);
        psCheck.setString(4, batchYear);
        psCheck.setString(5, department);
        psCheck.setString(6, "mid2");
        psCheck.setString(7, sid);
        ResultSet rs = psCheck.executeQuery();
        rs.next();
        int count = rs.getInt(1);
        rs.close();

        int ass = marks[12];
        int midmark = 0; // set if needed

        if(count > 0) {
            psUpdate.setInt(1, marks[0]);
            psUpdate.setInt(2, marks[1]);
            psUpdate.setInt(3, marks[2]);
            psUpdate.setInt(4, marks[3]);
            psUpdate.setInt(5, marks[4]);
            psUpdate.setInt(6, marks[5]);
            psUpdate.setInt(7, marks[6]);
            psUpdate.setInt(8, marks[7]);
            psUpdate.setInt(9, marks[8]);
            psUpdate.setInt(10, marks[9]);
            psUpdate.setInt(11, marks[10]);
            psUpdate.setInt(12, marks[11]);
            psUpdate.setInt(13, ass);
            psUpdate.setInt(14, midmark);
            psUpdate.setString(15, subjectId);
            psUpdate.setString(16, sem);
            psUpdate.setString(17, year);
            psUpdate.setString(18, batchYear);
            psUpdate.setString(19, department);
            psUpdate.setString(20, "mid2");
            psUpdate.setString(21, sid);
            psUpdate.executeUpdate();
        } else {
            psInsert.setString(1, sid);
            psInsert.setString(2, sem);
            psInsert.setString(3, year);
            psInsert.setString(4, batchYear);
            psInsert.setString(5, department);
            psInsert.setString(6, subjectId);
            psInsert.setString(7, "mid2");
            for(int i=0; i<12; i++) {
                psInsert.setInt(8+i, marks[i]);
            }
            psInsert.setInt(20, ass);
            psInsert.setInt(21, midmark);
            psInsert.executeUpdate();
        }
    }

    conn.commit();
%>

<script>
    if(confirm("Marks saved successfully! Click OK to continue.")) {
        window.location.href = "hodviewmarks.jsp";
    }
</script>

<%
} catch(Exception ex) {
    conn.rollback();
%>
    <p style="color:red;">Error saving marks: <%= ex.getMessage() %></p>
<%
} finally {
    if(conn != null) try { conn.close(); } catch(Exception e) {}
}
%>

