<%@ page import="java.util.*, java.sql.*" %>
<%@ page session="true" %>
<%
    List<Map<String, String>> studentList = new ArrayList<>();
    String subjectId = request.getParameter("subject_id");
    String subjectName = request.getParameter("subject_name");
    String sem = request.getParameter("sem");
    String year = request.getParameter("year");
    String batchYear = request.getParameter("batch_year");
    String department = request.getParameter("faculty_department");
    String error = "";

    if (subjectId != null && department != null && sem != null && year != null && batchYear != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/midmarks_db", "root", "");

            String sql = "SELECT s.student_id, s.student_name, m.mid1, m.mid2 " +
                         "FROM studentdetails s " +
                         "LEFT JOIN studentmidmarks m ON s.student_id = m.sid AND m.sub_id = ? " +
                         "WHERE s.student_department = ? AND s.stu_sem = ? AND s.stu_year = ? AND s.stu_batchyear = ?";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, subjectId);
            ps.setString(2, department);
            ps.setString(3, sem);
            ps.setString(4, year);
            ps.setString(5, batchYear);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> student = new HashMap<>();
                student.put("id", rs.getString("student_id"));
                student.put("name", rs.getString("student_name"));
                student.put("mid1", rs.getString("mid1") != null ? rs.getString("mid1") : "");
                student.put("mid2", rs.getString("mid2") != null ? rs.getString("mid2") : "");
                studentList.add(student);
            }

            rs.close();
            ps.close();
            con.close();
        } catch (Exception e) {
            error = "Error loading students: " + e.getMessage();
        }
    } else {
        error = "Missing parameters. Please go back and try again.";
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Enter Mid Marks - <%= subjectName %></title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f4f8;
            margin: 0;
            padding: 30px;
        }
        h2 {
            text-align: center;
            color: #2c3e50;
        }
        table {
            margin: 0 auto;
            border-collapse: collapse;
            width: 80%;
            background-color: #fff;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            border-radius: 8px;
            overflow: hidden;
        }
        th, td {
            padding: 12px 16px;
            text-align: center;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #3498db;
            color: white;
            font-size: 16px;
        }
        tr:hover {
            background-color: #f1f1f1;
        }
        input[type=number] {
            width: 60px;
            padding: 5px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        input[type=submit] {
            margin-top: 20px;
            display: block;
            margin-left: auto;
            margin-right: auto;
            background-color: #2ecc71;
            color: white;
            padding: 10px 25px;
            font-size: 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        input[type=submit]:hover {
            background-color: #27ae60;
        }
        p.error {
            text-align: center;
            color: red;
            font-weight: bold;
        }
    </style>
</head>
<body>

<h2>Enter Mid Marks - <%= subjectName %> (<%= subjectId %>)</h2>

<% if (!error.isEmpty()) { %>
    <p class="error"><%= error %></p>
<% } else if (studentList.isEmpty()) { %>
    <p class="error">No students found for this subject and semester.</p>
<% } else { %>
    <form action="SaveMarksServlet" method="post">
        <input type="hidden" name="subject_id" value="<%= subjectId %>">
        <input type="hidden" name="subject_name" value="<%= subjectName %>">
        <input type="hidden" name="sem" value="<%= sem %>">
        <input type="hidden" name="year" value="<%= year %>">
        <input type="hidden" name="batch_year" value="<%= batchYear %>">
        <input type="hidden" name="faculty_department" value="<%= department %>">

        <table>
            <tr>
                <th>Student ID</th>
                <th>Name</th>
                <th>Mid 1</th>
                <th>Mid 2</th>
            </tr>
            <% for (Map<String, String> student : studentList) { %>
                <tr>
                    <td><%= student.get("id") %></td>
                    <td><%= student.get("name") %></td>
                    <td>
                        <input type="number" name="mid1_<%= student.get("id") %>" value="<%= student.get("mid1") %>" min="0" max="100" required>
                    </td>
                    <td>
                        <input type="number" name="mid2_<%= student.get("id") %>" value="<%= student.get("mid2") %>" min="0" max="100" required>
                    </td>
                </tr>
            <% } %>
        </table><br>
        <input type="submit" value="Save Marks">
    </form>
<% } %>

</body>
</html>

