package servlet;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import db.DBConnection;

//@WebServlet("/GenerateAverageServlet")
public class GenerateAverageServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Map<String, String>> avgList = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Fetch all student mid marks
            String fetchSql = "SELECT sid, sname, subject, mid1, mid2 FROM studentmidmarks";
            PreparedStatement psFetch = conn.prepareStatement(fetchSql);
            ResultSet rs = psFetch.executeQuery();

            while (rs.next()) {
                String sid = rs.getString("sid");
                String sname = rs.getString("sname");
                String subject = rs.getString("subject");
                int mid1 = rs.getInt("mid1");
                int mid2 = rs.getInt("mid2");

                int higher = Math.max(mid1, mid2);
                int lower = Math.min(mid1, mid2);
                int avg = Math.round((higher * 0.8f) + (lower * 0.2f));

                // 2. Update average in DB
                String updateSql = "UPDATE studentmidmarks SET avg_marks = ? WHERE sid = ? AND subject = ?";
                PreparedStatement psUpdate = conn.prepareStatement(updateSql);
                psUpdate.setInt(1, avg);
                psUpdate.setString(2, sid);
                psUpdate.setString(3, subject);
                psUpdate.executeUpdate();

                // 3. Add to result list for display
                Map<String, String> row = new HashMap<>();
                row.put("sid", sid);
                row.put("sname", sname);
                row.put("subject", subject);
                row.put("avg", String.valueOf(avg));
                avgList.add(row);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("avgList", avgList);
        RequestDispatcher rd = request.getRequestDispatcher("hodAverageView.jsp");
        rd.forward(request, response);
    }
}
