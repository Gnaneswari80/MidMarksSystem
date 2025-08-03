<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.sql.*" %>
<%@ page import="db.DBConnection" %>
<html>
<head>
    <title>HOD Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f8;
            padding: 30px;
        }
        h2 {
            color: #2c3e50;
        }
        form {
            background-color: #ffffff;
            padding: 20px;
            margin-top: 20px;
            margin-bottom: 30px;
            border-radius: 8px;
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
        }
        input[type="text"] {
            padding: 8px;
            width: 200px;
            margin-bottom: 15px;
            border-radius: 5px;
            border: 1px solid #ccc;
        }
        input[type="submit"] {
            padding: 10px 20px;
            background-color: #007BFF;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #0056b3;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background-color: #ffffff;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            border-radius: 6px;
            overflow: hidden;
        }
        table, th, td {
            border: 1px solid #dddddd;
        }
        th, td {
            padding: 12px;
            text-align: center;
        }
        th {
            background-color: #007BFF;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        p {
            color: #d9534f;
            font-weight: bold;
        }
    </style>
</head>
<body>
<h2>Welcome HOD - <%= session.getAttribute("hod_department") %></h2>

<%
    List<Map<String, String>> students = (List<Map<String, String>>) request.getAttribute("studentList");
    if (students == null) {
%>
    <form action="HodLoadStudentsServlet" method="post">
        Semester: <input type="text" name="sem" required><br><br>
        Year: <input type="text" name="year" required><br><br>
        Batch Year: <input type="text" name="batch_year" required><br><br>
        <input type="submit" value="Fetch Students">
    </form>
<%
    } else {
        if (students.isEmpty()) {
%>
        <p>No students found.</p>
<%
        } else {
            Map<String, Map<String, String[]>> studentMap = new LinkedHashMap<>();
            Set<String> subjectSet = new LinkedHashSet<>();

            for (Map<String, String> s : students) {
                String sid = s.get("sid");
                String sname = s.get("sname");
                String subject = s.get("subject");
                String mid1 = s.get("mid1");
                String mid2 = s.get("mid2");

                subjectSet.add(subject);

                if (!studentMap.containsKey(sid)) {
                    studentMap.put(sid, new LinkedHashMap<>());
                    studentMap.get(sid).put("name", new String[]{sname});
                }
                studentMap.get(sid).put(subject, new String[]{mid1, mid2});
            }
%>
        <table>
            <tr>
                <th rowspan="2">ID</th>
                <th rowspan="2">Name</th>
                <% for (String subject : subjectSet) { %>
                    <th colspan="2"><%= subject %></th>
                <% } %>
            </tr>
            <tr>
                <% for (int i = 0; i < subjectSet.size(); i++) { %>
                    <th>Mid1</th>
                    <th>Mid2</th>
                <% } %>
            </tr>

            <% for (Map.Entry<String, Map<String, String[]>> entry : studentMap.entrySet()) {
                String sid = entry.getKey();
                Map<String, String[]> values = entry.getValue();
                String name = values.get("name")[0];
            %>
            <tr>
                <td><%= sid %></td>
                <td><%= name %></td>
                <% for (String subject : subjectSet) {
                    String[] marks = values.get(subject);
                    if (marks != null) {
                %>
                    <td><%= marks[0] %></td>
                    <td><%= marks[1] %></td>
                <%  } else { %>
                    <td>-</td>
                    <td>-</td>
                <%  } } %>
            </tr>
            <% } %>
        </table>

        <form action="GenerateAverageServlet" method="post">
            <input type="hidden" name="sem" value="<%= request.getParameter("sem") %>">
            <input type="hidden" name="year" value="<%= request.getParameter("year") %>">
            <input type="hidden" name="batch_year" value="<%= request.getParameter("batch_year") %>">
            <br>
            <input type="submit" value="Generate Average Marks">
        </form>
<%
        }
    }
%>

<form action="hodHomePage.jsp" method="get" style="text-align: center;">
  <input type="submit" value="Back to HOD Home">
</form>
</body>
</html>
