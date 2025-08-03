package servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import db.DBConnection;

public class InsertMarksServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        String sid = req.getParameter("sid");
        String sname = req.getParameter("sname");
        int mid1 = Integer.parseInt(req.getParameter("mid1"));
        int mid2 = Integer.parseInt(req.getParameter("mid2"));
        String subject = req.getParameter("subject");
        String subid = req.getParameter("subid");
        String sem = req.getParameter("sem");
        String year = req.getParameter("year");
        String batch = req.getParameter("batch");

        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement check = con.prepareStatement("SELECT * FROM studentmidmarks WHERE sid=? AND sub_id=?");
            check.setString(1, sid);
            check.setString(2, subid);
            ResultSet rs = check.executeQuery();

            if (rs.next()) {
                res.getWriter().println("Duplicate entry");
            } else {
                PreparedStatement ps = con.prepareStatement("INSERT INTO studentmidmarks VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL)");
                ps.setString(1, sid);
                ps.setString(2, sname);
                ps.setInt(3, mid1);
                ps.setInt(4, mid2);
                ps.setString(5, subject);
                ps.setString(6, subid);
                ps.setString(7, sem);
                ps.setString(8, year);
                ps.setString(9, batch);
                ps.executeUpdate();
                res.getWriter().println("Marks inserted");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
