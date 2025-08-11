<%@ page import="java.sql.*, java.util.*" %>
<%@ page session="true" %>

<%
    // Fetch session variables (adjust as per your session keys)
    String facultyId = (String) session.getAttribute("faculty_id");
    String department = (String) session.getAttribute("department");
    String sem = (String) session.getAttribute("sem");
    String year = (String) session.getAttribute("year");
    String batchYear = (String) session.getAttribute("batchYear");
    String subjectId = (String) session.getAttribute("subjectId");
    String subjectName = (String) session.getAttribute("subject_name");
    String mid = (String) session.getAttribute("mid");

    if (facultyId == null || department == null || sem == null || year == null || batchYear == null || subjectId == null || mid == null) {
        out.println("<p style='color:red;'>Session expired or missing data. Please login and select details again.</p>");
        return;
    }

    // Load student list with their current marks if any
    Map<String, Map<String, Integer>> studentMarks = new LinkedHashMap<>();
    Map<String, String> studentNames = new LinkedHashMap<>();

    // Initialize max marks to 0
    int max_1a=0, max_1b=0, max_2a=0, max_2b=0, max_3a=0, max_3b=0, max_4a=0, max_4b=0, max_5a=0, max_5b=0, max_6a=0, max_6b=0, max_ass=0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/midmarks_db", "root", "");

        // Load previously saved max marks if any (so we can show them as default values)
        PreparedStatement psMax = con.prepareStatement(
            "SELECT max_1a, max_1b, max_2a, max_2b, max_3a, max_3b, max_4a, max_4b, max_5a, max_5b, max_6a, max_6b, qmmass " +
            "FROM questionmaxmarks WHERE qmmBatchyear=? AND qmmSubjectId=? AND qmmMid=? AND qmmSem=? AND qmmYear=?"
        );
        psMax.setString(1, batchYear);
        psMax.setString(2, subjectId);
        psMax.setString(3, mid);
        psMax.setString(4, sem);
        psMax.setString(5, year);
        ResultSet rsMax = psMax.executeQuery();
        if (rsMax.next()) {
            max_1a = rsMax.getInt("max_1a");
            max_1b = rsMax.getInt("max_1b");
            max_2a = rsMax.getInt("max_2a");
            max_2b = rsMax.getInt("max_2b");
            max_3a = rsMax.getInt("max_3a");
            max_3b = rsMax.getInt("max_3b");
            max_4a = rsMax.getInt("max_4a");
            max_4b = rsMax.getInt("max_4b");
            max_5a = rsMax.getInt("max_5a");
            max_5b = rsMax.getInt("max_5b");
            max_6a = rsMax.getInt("max_6a");
            max_6b = rsMax.getInt("max_6b");
            max_ass = rsMax.getInt("qmmass");
        }
        rsMax.close();
        psMax.close();

        // Load existing student marks (if any)
        PreparedStatement psMarks = con.prepareStatement(
            "SELECT sid, sname, marks_1a, marks_1b, marks_2a, marks_2b, marks_3a, marks_3b, marks_4a, marks_4b, marks_5a, marks_5b, marks_6a, marks_6b, ass, midmark " +
            "FROM studentmidmarks WHERE sub_id=? AND student_sem=? AND student_year=? AND sbatch_year=? AND smmdepartment=? AND smmMid=? ORDER BY sid"
        );
        psMarks.setString(1, subjectId);
        psMarks.setString(2, sem);
        psMarks.setString(3, year);
        psMarks.setString(4, batchYear);
        psMarks.setString(5, department);
        psMarks.setString(6, mid);
        ResultSet rsMarks = psMarks.executeQuery();

        boolean marksExist = false;
        while (rsMarks.next()) {
            marksExist = true;
            String sid = rsMarks.getString("sid");
            studentNames.put(sid, rsMarks.getString("sname"));
            Map<String, Integer> marks = new HashMap<>();
            marks.put("marks_1a", rsMarks.getInt("marks_1a"));
            marks.put("marks_1b", rsMarks.getInt("marks_1b"));
            marks.put("marks_2a", rsMarks.getInt("marks_2a"));
            marks.put("marks_2b", rsMarks.getInt("marks_2b"));
            marks.put("marks_3a", rsMarks.getInt("marks_3a"));
            marks.put("marks_3b", rsMarks.getInt("marks_3b"));
            marks.put("marks_4a", rsMarks.getInt("marks_4a"));
            marks.put("marks_4b", rsMarks.getInt("marks_4b"));
            marks.put("marks_5a", rsMarks.getInt("marks_5a"));
            marks.put("marks_5b", rsMarks.getInt("marks_5b"));
            marks.put("marks_6a", rsMarks.getInt("marks_6a"));
            marks.put("marks_6b", rsMarks.getInt("marks_6b"));
            marks.put("ass", rsMarks.getInt("ass"));
            marks.put("midmark", rsMarks.getInt("midmark"));
            studentMarks.put(sid, marks);
        }
        rsMarks.close();
        psMarks.close();

        if (!marksExist) {
            // No existing marks, load students from studentdetails
            PreparedStatement psStudents = con.prepareStatement(
                "SELECT student_id, student_name FROM studentdetails WHERE student_department=? AND stu_sem=? AND stu_year=? AND stu_batchyear=? ORDER BY student_id"
            );
            psStudents.setString(1, department);
            psStudents.setString(2, sem);
            psStudents.setString(3, year);
            psStudents.setString(4, batchYear);
            ResultSet rsStudents = psStudents.executeQuery();

            while (rsStudents.next()) {
                String sid = rsStudents.getString("student_id");
                String sname = rsStudents.getString("student_name");
                studentNames.put(sid, sname);
                Map<String, Integer> marks = new HashMap<>();
                for (String f : Arrays.asList("marks_1a","marks_1b","marks_2a","marks_2b","marks_3a","marks_3b","marks_4a","marks_4b","marks_5a","marks_5b","marks_6a","marks_6b","ass","midmark")) {
                    marks.put(f, 0);
                }
                studentMarks.put(sid, marks);
            }
            rsStudents.close();
            psStudents.close();
        }

        con.close();

    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Enter Max Marks & Student Marks for <%= subjectName %> - <%= mid %></title>
    <style>
        .table-container {
            overflow-x: auto;
            margin-bottom: 20px;
        }
        table, th, td { 
            border: 1px solid black; 
            border-collapse: collapse; 
            padding: 5px; 
            white-space: nowrap;
        }
        th { background-color: #eee; }
        input[type=number] { width: 60px; }
        input[type=submit] {
            background-color: #007BFF;
            color: white;
            padding: 10px 18px;
            border: none;
            cursor: pointer;
            font-size: 16px;
            border-radius: 4px;
        }
        input[type=submit]:hover {
            background-color: #0056b3;
        }
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        h2 {
            color: #333;
        }
        .back-button:hover {
            background-color: #007bff;
            color: white;
        }
    </style>
    <script>
        function updateStudentMarksMax() {
            let maxInputs = {
                "marks_1a": parseInt(document.getElementById("max_1a").value) || 0,
                "marks_1b": parseInt(document.getElementById("max_1b").value) || 0,
                "marks_2a": parseInt(document.getElementById("max_2a").value) || 0,
                "marks_2b": parseInt(document.getElementById("max_2b").value) || 0,
                "marks_3a": parseInt(document.getElementById("max_3a").value) || 0,
                "marks_3b": parseInt(document.getElementById("max_3b").value) || 0,
                "marks_4a": parseInt(document.getElementById("max_4a").value) || 0,
                "marks_4b": parseInt(document.getElementById("max_4b").value) || 0,
                "marks_5a": parseInt(document.getElementById("max_5a").value) || 0,
                "marks_5b": parseInt(document.getElementById("max_5b").value) || 0,
                "marks_6a": parseInt(document.getElementById("max_6a").value) || 0,
                "marks_6b": parseInt(document.getElementById("max_6b").value) || 0,
                "ass": parseInt(document.getElementById("max_ass").value) || 0
            };

            for (let key in maxInputs) {
                let inputs = document.querySelectorAll("input[data-part='" + key + "']");
                inputs.forEach(function(input) {
                    input.max = maxInputs[key];
                    if (parseInt(input.value) > maxInputs[key]) {
                        input.value = maxInputs[key];
                    }
                });
            }
        }

        window.onload = function() {
            let maxInputIds = ["max_1a", "max_1b", "max_2a", "max_2b", "max_3a", "max_3b", "max_4a", "max_4b", "max_5a", "max_5b", "max_6a", "max_6b", "max_ass"];
            maxInputIds.forEach(function(id) {
                document.getElementById(id).addEventListener("input", updateStudentMarksMax);
            });
            updateStudentMarksMax();
        };
    </script>
</head>
<body>

<h2>Enter Max Marks & Student Marks for Subject: <%= subjectName %> (Batch: <%= batchYear %>, Dept: <%= department %>, Sem: <%= sem %>, Year: <%= year %>, Mid: <%= mid %>)</h2>

<form method="post" action="submitMarks.jsp">
    <input type="hidden" name="batchYear" value="<%= batchYear %>">
    <input type="hidden" name="subjectId" value="<%= subjectId %>">
    <input type="hidden" name="department" value="<%= department %>">
    <input type="hidden" name="sem" value="<%= sem %>">
    <input type="hidden" name="year" value="<%= year %>">
    <input type="hidden" name="mid" value="<%= mid %>">

    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th rowspan="2">Student ID</th>
                    <th rowspan="2">Student Name</th>
                    <th colspan="2">Q1</th>
                    <th colspan="2">Q2</th>
                    <th colspan="2">Q3</th>
                    <th colspan="2">Q4</th>
                    <th colspan="2">Q5</th>
                    <th colspan="2">Q6</th>
                    <th rowspan="2">Assignment (ass)</th>
                    <th rowspan="2">Mid Mark</th>
                </tr>
                <tr>
                    <th>1a</th><th>1b</th>
                    <th>2a</th><th>2b</th>
                    <th>3a</th><th>3b</th>
                    <th>4a</th><th>4b</th>
                    <th>5a</th><th>5b</th>
                    <th>6a</th><th>6b</th>
                </tr>
                <tr>
                    <th colspan="2">Max Marks</th>
                    <th><input type="number" id="max_1a" name="max_1a" value="<%= max_1a %>" min="0" required></th>
                    <th><input type="number" id="max_1b" name="max_1b" value="<%= max_1b %>" min="0" required></th>
                    <th><input type="number" id="max_2a" name="max_2a" value="<%= max_2a %>" min="0" required></th>
                    <th><input type="number" id="max_2b" name="max_2b" value="<%= max_2b %>" min="0" required></th>
                    <th><input type="number" id="max_3a" name="max_3a" value="<%= max_3a %>" min="0" required></th>
                    <th><input type="number" id="max_3b" name="max_3b" value="<%= max_3b %>" min="0" required></th>
                    <th><input type="number" id="max_4a" name="max_4a" value="<%= max_4a %>" min="0" required></th>
                    <th><input type="number" id="max_4b" name="max_4b" value="<%= max_4b %>" min="0" required></th>
                    <th><input type="number" id="max_5a" name="max_5a" value="<%= max_5a %>" min="0" required></th>
                    <th><input type="number" id="max_5b" name="max_5b" value="<%= max_5b %>" min="0" required></th>
                    <th><input type="number" id="max_6a" name="max_6a" value="<%= max_6a %>" min="0" required></th>
                    <th><input type="number" id="max_6b" name="max_6b" value="<%= max_6b %>" min="0" required></th>
                    <th><input type="number" id="max_ass" name="max_ass" value="<%= max_ass %>" min="0" required></th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <%
                    for (Map.Entry<String, String> student : studentNames.entrySet()) {
                        String sid = student.getKey();
                        String sname = student.getValue();
                        Map<String, Integer> marks = studentMarks.get(sid);

                        out.print("<tr>");
                        out.print("<td>" + sid + "</td>");
                        out.print("<td>" + sname + "</td>");

                        String[] fields = {"marks_1a", "marks_1b", "marks_2a", "marks_2b", "marks_3a", "marks_3b", "marks_4a", "marks_4b", "marks_5a", "marks_5b", "marks_6a", "marks_6b"};

                        for (String field : fields) {
                            int val = marks.getOrDefault(field, 0);
                            out.print("<td><input type='number' data-part='" + field + "' name='" + field + "_" + sid + "' value='" + val + "' min='0' required></td>");
                        }

                        int assVal = marks.getOrDefault("ass", 0);
                        out.print("<td><input type='number' data-part='ass' name='ass_" + sid + "' value='" + assVal + "' min='0' required></td>");

                        int midMarkVal = marks.getOrDefault("midmark", 0);
                        out.print("<td><input type='number' name='midmark_" + sid + "' value='" + midMarkVal + "' min='0' max='999' required></td>");

                        out.print("</tr>");
                    }
                %>
            </tbody>
        </table>
    </div>

    <br>
    <input type="submit" value="Save All Marks">&nbsp; &nbsp;&nbsp;&nbsp;   <a href="getSubjects.jsp" class="back-button">&#8592; Back</a>
</form>

</body>
</html>
