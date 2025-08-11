<%@ page import="java.sql.*,java.util.*" %> 
<%@ page session="true" %>
<%
String batchYear=(String)session.getAttribute("batchYear");
String sem=(String)session.getAttribute("sem");
String year=(String)session.getAttribute("year");
String dep=(String)session.getAttribute("hod_department");
String subjectId=(String)session.getAttribute("selectedSubjectId");
String subjectName=(String)session.getAttribute("selectedSubjectName");
if(batchYear==null||sem==null||year==null||dep==null||subjectId==null||subjectName==null){ %>
<p>Please complete all selections (department,sem,year,batchYear,subject) before viewing marks.</p>
<% return;} 
class MarksData{String sid,sname;int[] marks=new int[13];}
Map<String,MarksData> mid1Data=new LinkedHashMap<>();
Map<String,MarksData> mid2Data=new LinkedHashMap<>();
int[] max1=new int[13],max2=new int[13];
Connection conn=null;
PreparedStatement pst=null;
ResultSet rs=null;
try{
Class.forName("com.mysql.cj.jdbc.Driver");
conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/midmarks_db","root","");
String maxQuery="SELECT max_1a,max_1b,max_2a,max_2b,max_3a,max_3b,"+
"max_4a,max_4b,max_5a,max_5b,max_6a,max_6b,qmmass "+
"FROM questionmaxmarks WHERE qmmBatchyear=? AND qmmSubjectId=? AND qmmSem=? AND qmmYear=? AND qmmMid=?";
pst=conn.prepareStatement(maxQuery);
pst.setString(1,batchYear);pst.setString(2,subjectId);pst.setString(3,sem);pst.setString(4,year);pst.setString(5,"mid1");
rs=pst.executeQuery();
if(rs.next()){
for(int i=0;i<12;i++){max1[i]=rs.getInt(i+1);}
max1[12]=rs.getInt("qmmass");}
rs.close();pst.close();
pst=conn.prepareStatement(maxQuery);
pst.setString(1,batchYear);pst.setString(2,subjectId);pst.setString(3,sem);pst.setString(4,year);pst.setString(5,"mid2");
rs=pst.executeQuery();
if(rs.next()){
for(int i=0;i<12;i++){max2[i]=rs.getInt(i+1);}
max2[12]=rs.getInt("qmmass");}
rs.close();pst.close();
String studentQuery="SELECT sid,sname,marks_1a,marks_1b,marks_2a,marks_2b,marks_3a,marks_3b,"+
"marks_4a,marks_4b,marks_5a,marks_5b,marks_6a,marks_6b,ass "+
"FROM studentmidmarks WHERE sbatch_year=? AND sub_id=? AND student_sem=? AND student_year=? AND smmdepartment=? AND smmMid=? ORDER BY sid";
pst=conn.prepareStatement(studentQuery);
pst.setString(1,batchYear);pst.setString(2,subjectId);pst.setString(3,sem);pst.setString(4,year);pst.setString(5,dep);pst.setString(6,"mid1");
rs=pst.executeQuery();
while(rs.next()){
MarksData md=new MarksData();
md.sid=rs.getString("sid");
md.sname=rs.getString("sname");
for(int i=0;i<12;i++){md.marks[i]=rs.getInt(i+3);}
md.marks[12]=rs.getInt("ass");
mid1Data.put(md.sid,md);}
rs.close();pst.close();
pst=conn.prepareStatement(studentQuery);
pst.setString(1,batchYear);pst.setString(2,subjectId);pst.setString(3,sem);pst.setString(4,year);pst.setString(5,dep);pst.setString(6,"mid2");
rs=pst.executeQuery();
while(rs.next()){
MarksData md=new MarksData();
md.sid=rs.getString("sid");
md.sname=rs.getString("sname");
for(int i=0;i<12;i++){md.marks[i]=rs.getInt(i+3);}
md.marks[12]=rs.getInt("ass");
mid2Data.put(md.sid,md);}
rs.close();pst.close();
}catch(Exception e){out.println("Error: "+e.getMessage());}
finally{if(conn!=null)try{conn.close();}catch(Exception e){}}
%>
<!DOCTYPE html>
<html>
<head>
<title>HOD View Marks</title>
<style>
body{font-family:Arial,sans-serif;padding:15px;background:#f7f7f7;}
h2,h3{color:#004080;}
div.table-wrapper{overflow-x:auto;}
table{border-collapse:collapse;width:100%;box-shadow:0 0 8px #ccc;background:white;}
th,td{border:1px solid #aaa;padding:2px;text-align:center;font-size:14px;}
th{background-color:#004080;color:white;}
.assign{background-color:#ffe4e1;font-weight:bold;}
.total{font-weight:bold;background-color:#d9f7be;}
input[type=number]{width:40px;border:1px solid #ccc;border-radius:3px;text-align:center;}
</style>
</head>
<body>
    <button onclick="window.location.href='hodsubjectselection.jsp'" 
            style="position:absolute; top:10px; left:10px; padding:6px 12px; font-size:14px; cursor:pointer;">
        &larr; Back
    </button>

<h2>View Marks for Subject: <%=subjectName%> (<%=subjectId%>)</h2>
<h3>Department: <%=dep%>, Sem: <%=sem%>, Year: <%=year%>, Batch Year: <%=batchYear%></h3>

<form method="post" action="hodsavemarks.jsp">
    <input type="hidden" name="batchYear" value="<%=batchYear%>">
    <input type="hidden" name="sem" value="<%=sem%>">
    <input type="hidden" name="year" value="<%=year%>">
    <input type="hidden" name="department" value="<%=dep%>">
    <input type="hidden" name="subjectId" value="<%=subjectId%>">

    <div class="table-wrapper">
        <table>
            <thead>
            <tr><th rowspan="2">ID</th><th rowspan="2">Name</th><th colspan="14">Mid1</th><th colspan="14">Mid2</th></tr>
            <tr>
                <% for(int i=0;i<12;i++){ %><th><%= (i/2+1) %><%= (i%2==0?"a":"b") %></th><% } %>
                <th class="assign">Ass</th><th>Total</th>
                <% for(int i=0;i<12;i++){ %><th><%= (i/2+1) %><%= (i%2==0?"a":"b") %></th><% } %>
                <th class="assign">Ass</th><th>Total</th>
            </tr>
            <tr>
                <td colspan="2"><b>Max Marks</b></td>
                <% int totalMax1=0; for(int i=0;i<13;i++){totalMax1+=max1[i]; %>
                <td><input type="number" id="max1_<%=i%>" name="max1_<%=i%>" value="<%=max1[i]%>" min="0" step="1" oninput="updateMaxMarks('max1', <%=i%>)"></td>
                <% } %>
                <td class="total" id="max1_total"><%=totalMax1%></td>
                <% int totalMax2=0; for(int i=0;i<13;i++){totalMax2+=max2[i]; %>
                <td><input type="number" id="max2_<%=i%>" name="max2_<%=i%>" value="<%=max2[i]%>" min="0" step="1" oninput="updateMaxMarks('max2', <%=i%>)"></td>
                <% } %>
                <td class="total" id="max2_total"><%=totalMax2%></td>
            </tr>
            </thead>
            <tbody>
            <% for(String sid:mid1Data.keySet()){ MarksData m1=mid1Data.get(sid); MarksData m2=mid2Data.get(sid); %>
            <tr><td><%=m1.sid%></td><td><%=m1.sname%></td>
                <% int totalM1=0; for(int i=0;i<13;i++){ int val=m1.marks[i]; totalM1+=val; %>
                <td><input type="number" id="mid1_<%=sid%>_<%=i%>" name="mid1_<%=sid%>_<%=i%>" value="<%=val%>" min="0" step="1" max="<%=max1[i]%>" oninput="updateStudentTotal('<%=sid%>','mid1')"></td>
                <% } %>
                <td class="total" id="total_mid1_<%=sid%>"><%=totalM1%></td>
                <% int totalM2=0; if(m2!=null){ for(int i=0;i<13;i++){ int val=m2.marks[i]; totalM2+=val; %>
                <td><input type="number" id="mid2_<%=sid%>_<%=i%>" name="mid2_<%=sid%>_<%=i%>" value="<%=val%>" min="0" step="1" max="<%=max2[i]%>" oninput="updateStudentTotal('<%=sid%>','mid2')"></td>
                <% } } else { for(int i=0;i<13;i++){ %>
                <td><input type="number" id="mid2_<%=sid%>_<%=i%>" name="mid2_<%=sid%>_<%=i%>" value="0" min="0" step="1" max="<%=max2[i]%>" oninput="updateStudentTotal('<%=sid%>','mid2')"></td>
                <% } totalM2=0;} %>
                <td class="total" id="total_mid2_<%=sid%>"><%=totalM2%></td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>

    <button type="submit" style="margin-top:10px; padding:8px 15px; font-size:16px;">Save Marks</button>
</form>

<script>
// Update total max marks and adjust student inputs max accordingly
function updateMaxMarks(prefix, index){
    let maxInput = document.getElementById(prefix + "_" + index);
    let val = parseInt(maxInput.value) || 0;

    // Update total
    let total = 0;
    for(let i=0;i<13;i++){
        let inp = document.getElementById(prefix + "_" + i);
        if(inp) total += parseInt(inp.value) || 0;
    }
    document.getElementById(prefix + "_total").innerText = total;

    // Determine mid string from prefix
    let mid = (prefix === 'max1') ? 'mid1' : 'mid2';

    // Update max attribute of all corresponding student inputs for this question (index)
    let selector = "input[name^='" + mid + "_'][name$='_" + index + "']";
    let inputs = document.querySelectorAll(selector);
    inputs.forEach(function(input){
        input.max = val;
        if(parseInt(input.value) > val){
            input.value = val;
            let sid = input.name.split('_')[1]; // mid1_sid_i
            updateStudentTotal(sid, mid);
        }
    });
}

// Update total marks for a student for a given mid
function updateStudentTotal(sid, mid){
    let total=0;
    for(let i=0;i<13;i++){
        let el=document.getElementsByName(mid + "_" + sid + "_" + i)[0];
        if(el){
            let val=parseInt(el.value)||0;
            total+=val;
        }
    }
    let totalEl = document.getElementById('total_'+mid+'_'+sid);
    if(totalEl) totalEl.innerText = total;
}

// Initialize totals and max constraints on load
window.onload=function(){
    for(let prefix of ['max1', 'max2']){
        let total = 0;
        for(let i=0; i<13; i++){
            let inp = document.getElementById(prefix + "_" + i);
            if(inp) total += parseInt(inp.value) || 0;
        }
        document.getElementById(prefix + "_total").innerText = total;
    }
    <% for(String sid:mid1Data.keySet()){ %>
        updateStudentTotal('<%=sid%>', 'mid1');
        updateStudentTotal('<%=sid%>', 'mid2');
        for(let i=0;i<13;i++){
            let max1Val = parseInt(document.getElementById('max1_'+i).value) || 0;
            let max2Val = parseInt(document.getElementById('max2_'+i).value) || 0;
            let mid1Input = document.getElementsByName('mid1_<%=sid%>_' + i)[0];
            let mid2Input = document.getElementsByName('mid2_<%=sid%>_' + i)[0];
            if(mid1Input) mid1Input.max = max1Val;
            if(mid2Input) mid2Input.max = max2Val;
        }
    <% } %>
};
</script>

</body>
</html>

