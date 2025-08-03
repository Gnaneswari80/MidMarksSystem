<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>HOD - View Student Marks</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f3f3f3;
            margin: 0;
            padding: 20px;
        }
        h2 {
            text-align: center;
            color: #333;
        }
        table {
            border-collapse: collapse;
            width: 95%;
            margin: 20px auto;
            background-color: #fff;
        }
        th, td {
            border: 1px solid #999;
            padding: 10px;
            text-align: center;
            vertical-align: middle;
        }
        th {
            background-color: #4CAF50;
            color: white;
        }
        .button-container {
            text-align: center;
            margin-top: 20px;
        }
        input[type="submit"] {
            padding: 8px 20px;
            font-size: 14px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .no-data {
            text-align: center;
            font-size: 18px;
            color: #666;
        }
    </style>
</head>
<body>

<h2>Student Mid Marks</h2>

<div class="button-container">
    <form action="GenerateAverageServlet" method="post">
        <input type="submit" value="Generate Average">
    </form>
</div>

<%
    List<Map<String, String>> studentList = (List<Map<String, String>>) request.getAttribute("studentList");

    if (studentList != null && !studentList.isEmpty()) {
        Set<String> subjects = new LinkedHashSet<>();
        Map<String, Map<String, Object>> groupedData = new LinkedHashMap<>();

        for (Map<String, String> row : studentList) {
            String sid = row.get("sid");
            String sname = row.get("sname");
            String subject = row.get("subject");
            String mid1 = row.get("mid1");
            String mid2 = row.get("mid2");

            subjects.add(subject);

            if (!groupedData.containsKey(sid)) {
                Map<String, Object> stu = new HashMap<>();
                stu.put("sid", sid);
                stu.put("sname", sname);
                groupedData.put(sid, stu);
            }

            groupedData.get(sid).put(subject, "Mid1: " + mid1 + "<br>Mid2: " + mid2);
        }
%>

<table>
    <tr>
        <th>Student ID</th>
        <th>Name</th>
        <% for (String sub : subjects) { %>
            <th><%= sub %></th>
        <% } %>
    </tr>

    <% for (Map<String, Object> stu : groupedData.values()) { %>
        <tr>
            <td><%= stu.get("sid") %></td>
            <td><%= stu.get("sname") %></td>
            <% for (String sub : subjects) { %>
                <td><%= stu.get(sub) != null ? stu.get(sub) : "-" %></td>
            <% } %>
        </tr>
    <% } %>
</table>

<%
    } else {
%>
    <p class="no-data">No student data found.</p>
<%
    }
%>

</body>
</html>
