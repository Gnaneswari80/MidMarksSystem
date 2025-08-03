package servlet;

import db.DBConnection;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

//@WebServlet("/HodLoadStudentsServlet")
public class HodLoadStudentsServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String sem = request.getParameter("sem");
        String year = request.getParameter("year");
        String batchYear = request.getParameter("batch_year");

        List<Map<String, String>> studentList = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT sid, sname, subject, mid1, mid2, avg_marks " +
                         "FROM studentmidmarks " +
                         "WHERE student_sem = ? AND student_year = ? AND sbatch_year = ?";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, sem);
                ps.setString(2, year);
                ps.setString(3, batchYear);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> student = new HashMap<>();
                        student.put("sid", rs.getString("sid"));
                        student.put("sname", rs.getString("sname"));
                        student.put("subject", rs.getString("subject"));
                        student.put("mid1", rs.getString("mid1"));
                        student.put("mid2", rs.getString("mid2"));
                        student.put("avg_marks", rs.getString("avg_marks"));
                        studentList.add(student);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("studentList", studentList);
        RequestDispatcher rd = request.getRequestDispatcher("hodDashboard.jsp");
        rd.forward(request, response);
    }
}
