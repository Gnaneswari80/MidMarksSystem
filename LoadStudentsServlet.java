package servlet;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import db.DBConnection;

public class LoadStudentsServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String sem   = request.getParameter("sem");
        String year  = request.getParameter("year");
        String batch = request.getParameter("batch");

        List<Map<String, String>> studentList = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT DISTINCT sid, sname, mid1, mid2 "
                       + "FROM studentmidmarks "
                       + "WHERE student_sem  = ? "
                       +   "AND student_year = ? "
                       +   "AND sbatch_year = ?";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, sem);
                ps.setString(2, year);
                ps.setString(3, batch);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> student = new HashMap<>();
                        student.put("id",   rs.getString("sid"));
                        student.put("name", rs.getString("sname"));
                        student.put("mid1", rs.getString("mid1"));
                        student.put("mid2", rs.getString("mid2"));
                        studentList.add(student);
                    }
                }
            }

            // attach to request and forward
            request.setAttribute("studentList", studentList);
            request.getRequestDispatcher("hodViewMarks.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Error fetching student midmarks", e);
        }
    }
}
