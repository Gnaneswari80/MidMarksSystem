<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>MidMarks System - Home</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f4f4;
        }

        .header {
            text-align: center;
            background-color: #002147;
            padding: 20px 10px;
        }

        .header img {
            width: 80%;
            max-width: 900px;
            height: auto;
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        }

        .marquee-text {
            color: #ffffff;
            font-size: 18px;
            font-weight: bold;
            margin-top: 10px;
        }

        .container {
            background-color: white;
            margin: 40px auto;
            padding: 40px;
            width: 50%;
            text-align: center;
            border-radius: 10px;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
        }

        h2 {
            font-size: 28px;
            margin-bottom: 30px;
            color: #333;
        }

        a {
            display: inline-block;
            margin: 15px 10px;
            padding: 12px 25px;
            font-size: 16px;
            color: #fff;
            background-color: #007BFF;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            transition: background-color 0.3s ease;
        }

        a:hover {
            background-color: #0056b3;
        }

        @media (max-width: 768px) {
            .container {
                width: 90%;
                padding: 30px 15px;
            }

            .header img {
                width: 95%;
            }
        }
    </style>
</head>
<body>

    <div class="header">
        <img src="https://www.sietk.org/images/1.png" alt="Siddhartha Institute of Engineering & Technology, Puttur">
        <marquee class="marquee-text" behavior="scroll" direction="left">
            Siddharth Institute of Engineering & Technology, Puttur
        </marquee>
    </div>

    <div class="container">
        <h2>Welcome to MidMarks Management System</h2>
        <a href="facultyLogin.jsp">Faculty Login</a>
        <a href="hodLogin.jsp">HOD Login</a>
    </div>

</body>
</html>
