package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import db.DBConnection;

public class SubmitMarksServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        String[] studentIds = req.getParameterValues("sid");
        String[] studentNames = req.getParameterValues("sname");
        String[] mid1Marks = req.getParameterValues("mid1");
        String[] mid2Marks = req.getParameterValues("mid2");

        String subjectId = req.getParameter("subject_id");
        String subjectName = req.getParameter("subject_name");
        String sem = req.getParameter("sem");
        String year = req.getParameter("year");

        HttpSession session = req.getSession();
        String dept = (String) session.getAttribute("faculty_department");

        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO studentmidmarks (sid, sname, mid1, mid2, subject, sub_id, student_sem, student_year, sbatch_year, avg_marks) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

            for (int i = 0; i < studentIds.length; i++) {
                int m1 = Integer.parseInt(mid1Marks[i]);
                int m2 = Integer.parseInt(mid2Marks[i]);
                int avg = (m1 + m2) / 2;

                ps.setString(1, studentIds[i]);
                ps.setString(2, studentNames[i]);
                ps.setInt(3, m1);
                ps.setInt(4, m2);
                ps.setString(5, subjectName);
                ps.setString(6, subjectId);
                ps.setString(7, sem);
                ps.setString(8, year);
                ps.setString(9, dept); // sbatch_year as department (you can change if needed)
                ps.setInt(10, avg);

                ps.addBatch();
            }

            ps.executeBatch();
            res.getWriter().println("<h3>Marks submitted successfully!</h3>");
            res.getWriter().println("<a href='facultyDashboard.jsp'>Back to Dashboard</a>");

        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().println("Error occurred while submitting marks.");
        }
    }
}
