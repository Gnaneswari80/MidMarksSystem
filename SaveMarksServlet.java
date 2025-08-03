package servlet;

import db.DBConnection;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class SaveMarksServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String subjectId = request.getParameter("subject_id");
        String subjectName = request.getParameter("subject_name");
        String sem = request.getParameter("sem");
        String year = request.getParameter("year");
        String batchYear = request.getParameter("batch_year");
        String department = request.getParameter("faculty_department");

        try (Connection con = DBConnection.getConnection()) {
            String fetchStudentsSql = "SELECT student_id FROM studentdetails WHERE student_department = ? AND stu_sem = ? AND stu_year = ? AND stu_batchyear = ?";
            PreparedStatement fetchStmt = con.prepareStatement(fetchStudentsSql);
            fetchStmt.setString(1, department);
            fetchStmt.setString(2, sem);
            fetchStmt.setString(3, year);
            fetchStmt.setString(4, batchYear);
            ResultSet rs = fetchStmt.executeQuery();

            while (rs.next()) {
                String sid = rs.getString("student_id");
                String mid1Str = request.getParameter("mid1_" + sid);
                String mid2Str = request.getParameter("mid2_" + sid);

                if (mid1Str != null && mid2Str != null && !mid1Str.isEmpty() && !mid2Str.isEmpty()) {
                    int mid1 = Integer.parseInt(mid1Str);
                    int mid2 = Integer.parseInt(mid2Str);

                    // Check if record already exists
                    String checkSql = "SELECT * FROM studentmidmarks WHERE sid = ? AND sub_id = ?";
                    PreparedStatement checkStmt = con.prepareStatement(checkSql);
                    checkStmt.setString(1, sid);
                    checkStmt.setString(2, subjectId);
                    ResultSet checkRs = checkStmt.executeQuery();

                    if (checkRs.next()) {
                        // Update
                        String updateSql = "UPDATE studentmidmarks SET mid1 = ?, mid2 = ? WHERE sid = ? AND sub_id = ?";
                        PreparedStatement updateStmt = con.prepareStatement(updateSql);
                        updateStmt.setInt(1, mid1);
                        updateStmt.setInt(2, mid2);
                        updateStmt.setString(3, sid);
                        updateStmt.setString(4, subjectId);
                        updateStmt.executeUpdate();
                    } else {
                        // Insert
                        String studentName = getStudentNameById(con, sid);
                        String insertSql = "INSERT INTO studentmidmarks (sid, sname, mid1, mid2, subject, sub_id, student_sem, student_year, sbatch_year) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                        PreparedStatement insertStmt = con.prepareStatement(insertSql);
                        insertStmt.setString(1, sid);
                        insertStmt.setString(2, studentName);
                        insertStmt.setInt(3, mid1);
                        insertStmt.setInt(4, mid2);
                        insertStmt.setString(5, subjectName);
                        insertStmt.setString(6, subjectId);
                        insertStmt.setString(7, sem);
                        insertStmt.setString(8, year);
                        insertStmt.setString(9, batchYear);
                        insertStmt.executeUpdate();
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        // Show success message and redirect
        response.setContentType("text/html");
        response.getWriter().println("<html><head>" +
                "<meta http-equiv='refresh' content='3;URL=facultyDashboard.jsp' />" +
                "<style>" +
                "body { font-family: Arial; text-align: center; margin-top: 100px; background-color: #f0f8ff; }" +
                "h2 { color: green; }" +
                "</style></head><body>" +
                "<h2>✅ Marks Saved Successfully!</h2>" +
                "<p>You will be redirected to Faculty Dashboard shortly...</p>" +
                "</body></html>");
    }

    private String getStudentNameById(Connection con, String sid) throws SQLException {
        String sql = "SELECT student_name FROM studentdetails WHERE student_id = ?";
        try (PreparedStatement stmt = con.prepareStatement(sql)) {
            stmt.setString(1, sid);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getString("student_name");
            }
        }
        return "";
    }
}
