<%@ page contentType="text/html; charset=euc-kr"%>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page import="org.json.simple.parser.JSONParser" %>
<%@ page import="org.apache.commons.codec.binary.Hex" %>
<%
request.setCharacterEncoding("euc-kr"); 

/*
****************************************************************************************
* <��ҿ�û �Ķ����>
* ��ҽ� �����ϴ� �Ķ�����Դϴ�.
* ���������������� �⺻(�ʼ�) �Ķ���͸� ���õǾ� ������, 
* �߰� ������ �ɼ� �Ķ���ʹ� �����޴����� �����ϼ���.
****************************************************************************************
*/
String tid 					= (String)request.getParameter("TID");	// �ŷ� ID
String cancelAmt 			= (String)request.getParameter("CancelAmt");	// ��ұݾ�
String partialCancelCode 	= (String)request.getParameter("PartialCancelCode"); 	// �κ���ҿ���
String mid 					= "nicepay00m";	// ���� ID
String moid					= "nicepay_api_3.0_test";	// �ֹ���ȣ
String cancelMsg 			= "����û";	// ��һ���

/*
****************************************************************************************
* <�ؽ���ȣȭ> (�������� ������)
* SHA-256 �ؽ���ȣȭ�� �ŷ� �������� �������� ����Դϴ�. 
****************************************************************************************
*/
DataEncrypt sha256Enc 	= new DataEncrypt();
String merchantKey 		= "EYzu8jGGMfqaDEp76gSckuvnaHHu+bC4opsSN6lHv3b2lurNYkVXrZ7Z1AoqQnXI3eLuaUFyoRNC6FkrzVjceg=="; // ����Ű
String ediDate			= getyyyyMMddHHmmss();
String signData 		= sha256Enc.encrypt(mid + cancelAmt + ediDate + merchantKey);

/*
****************************************************************************************
* <��� ��û>
* ��ҿ� �ʿ��� ������ ���� �� server to server ����� ���� ��� ó�� �մϴ�.
* ��� ����(CancelMsg) �� ���� �ѱ� �ؽ�Ʈ�� �ʿ��� �Ķ���ʹ� euc-kr encoding ó���� �ʿ��մϴ�.
****************************************************************************************
*/
StringBuffer requestData = new StringBuffer();
requestData.append("TID=").append(tid).append("&");
requestData.append("MID=").append(mid).append("&");
requestData.append("Moid=").append(moid).append("&");
requestData.append("CancelAmt=").append(cancelAmt).append("&");
requestData.append("CancelMsg=").append(URLEncoder.encode(cancelMsg, "euc-kr")).append("&");
requestData.append("PartialCancelCode=").append(partialCancelCode).append("&");
requestData.append("EdiDate=").append(ediDate).append("&");
requestData.append("SignData=").append(signData);
String resultJsonStr = connectToServer(requestData.toString(), "https://webapi.nicepay.co.kr/webapi/cancel_process.jsp");

/*
****************************************************************************************
* <��� ��� �Ķ���� ����>
* ���������������� ��� ��� �Ķ���� �� �Ϻθ� ���õǾ� ������, 
* �߰������� ����Ͻ� �Ķ���ʹ� �����޴����� �����ϼ���.
****************************************************************************************
*/
String ResultCode 	= ""; String ResultMsg 	= ""; String CancelAmt 	= "";
String CancelDate 	= ""; String CancelTime = ""; String TID 		= ""; 

/*  
****************************************************************************************
* Signature : ��û �����Ϳ� ���� ���Ἲ ������ ���� �����ϴ� �Ķ���ͷ� ���� ���� ��û �� ���� �� ���� ���� �̽��� �߻��� ���� ��Ҹ� �����ϱ� ���� ���� �� ����Ͻñ� �ٶ�� 
* ������ ���� �̻������ ���� �߻��ϴ� �̽��� ����� å���� ���� �����Ͻñ� �ٶ��ϴ�.
****************************************************************************************
 */
//String Signature = ""; String cancelSignature = "";

if("9999".equals(resultJsonStr)){
	ResultCode 	= "9999";
	ResultMsg	= "��Ž���";
}else{
	HashMap resultData = jsonStringToHashMap(resultJsonStr);
	ResultCode 	= (String)resultData.get("ResultCode");	// ����ڵ� (��Ҽ���: 2001, ��Ҽ���(LGU ������ü):2211)
	ResultMsg 	= (String)resultData.get("ResultMsg");	// ����޽���
	CancelAmt 	= (String)resultData.get("CancelAmt");	// ��ұݾ�
	CancelDate 	= (String)resultData.get("CancelDate");	// �����
	CancelTime 	= (String)resultData.get("CancelTime");	// ��ҽð�
	TID 		= (String)resultData.get("TID");		// �ŷ����̵� TID
	//Signature       	= (String)resultData.get("Signature");
	//cancelSignature = sha256Enc.encrypt(TID + mid + CancelAmt + merchantKey);
}
%>
<!DOCTYPE html>
<html>
<head>
<title>NICEPAY CANCEL RESULT(EUC-KR)</title>
<meta charset="euc-kr">
</head>
<body> 
	<table>
		<tr>
			<th>��� ��� ����</th>
			<td>[<%=ResultCode%>]<%=ResultMsg%></td>
		</tr>
		<tr>
			<th>�ŷ� ���̵�</th>
			<td><%=TID%></td>
		</tr>
		<tr>
			<th>��� �ݾ�</th>
			<td><%=CancelAmt%></td>
		</tr>
		<tr>
			<th>�����</th>
			<td><%=CancelDate%></td>
		</tr>
		<tr>
			<th>��ҽð�</th>
			<td><%=CancelTime%></td>
		</tr>
		<!--<%/*if(Signature.equals(cancelSignature)){%>
		<tr>
			<th>Signature</th>
			<td><%=Signature%></td>
		</tr>
		<%}else{%>
		<tr>
			<th>���� Signature</th>
			<td><%=Signature%></td>
		</tr>
		<tr>
			<th>���� Signature</th>
			<td><%=cancelSignature%></td>
		</tr>-->
		<%}*/%>
	</table>
</body>
</html>
<%!
public final synchronized String getyyyyMMddHHmmss(){
	SimpleDateFormat yyyyMMddHHmmss = new SimpleDateFormat("yyyyMMddHHmmss");
	return yyyyMMddHHmmss.format(new Date());
}

//SHA-256 �������� ��ȣȭ
public class DataEncrypt{
	MessageDigest md;
	String strSRCData = "";
	String strENCData = "";
	String strOUTData = "";
	
	public DataEncrypt(){ }
	public String encrypt(String strData){
		String passACL = null;
		MessageDigest md = null;
		try{
			md = MessageDigest.getInstance("SHA-256");
			md.reset();
			md.update(strData.getBytes());
			byte[] raw = md.digest();
			passACL = encodeHex(raw);
		}catch(Exception e){
			System.out.print("��ȣȭ ����" + e.toString());
		}
		return passACL;
	}
	
	public String encodeHex(byte [] b){
		char [] c = Hex.encodeHex(b);
		return new String(c);
	}
}

//server to server ���
public String connectToServer(String data, String reqUrl) throws Exception{
	HttpURLConnection conn 		= null;
	BufferedReader resultReader = null;
	PrintWriter pw 				= null;
	URL url 					= null;
	
	int statusCode = 0;
	StringBuffer recvBuffer = new StringBuffer();
	try{
		url = new URL(reqUrl);
		conn = (HttpURLConnection) url.openConnection();
		conn.setRequestMethod("POST");
		conn.setConnectTimeout(15000);
		conn.setReadTimeout(25000);
		conn.setDoOutput(true);
		
		pw = new PrintWriter(conn.getOutputStream());
		pw.write(data);
		pw.flush();
		
		statusCode = conn.getResponseCode();
		resultReader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "euc-kr"));
		for(String temp; (temp = resultReader.readLine()) != null;){
			recvBuffer.append(temp).append("\n");
		}
		
		if(!(statusCode == HttpURLConnection.HTTP_OK)){
			throw new Exception();
		}
		
		return recvBuffer.toString().trim();
	}catch (Exception e){
		return "9999";
	}finally{
		recvBuffer.setLength(0);
		
		try{
			if(resultReader != null){
				resultReader.close();
			}
		}catch(Exception ex){
			resultReader = null;
		}
		
		try{
			if(pw != null) {
				pw.close();
			}
		}catch(Exception ex){
			pw = null;
		}
		
		try{
			if(conn != null) {
				conn.disconnect();
			}
		}catch(Exception ex){
			conn = null;
		}
	}
}

//JSON String -> HashMap ��ȯ
private static HashMap jsonStringToHashMap(String str) throws Exception{
	HashMap dataMap = new HashMap();
	JSONParser parser = new JSONParser();
	try{
		Object obj = parser.parse(str);
		JSONObject jsonObject = (JSONObject)obj;

		Iterator<String> keyStr = jsonObject.keySet().iterator();
		while(keyStr.hasNext()){
			String key = keyStr.next();
			Object value = jsonObject.get(key);
			
			dataMap.put(key, value);
		}
	}catch(Exception e){
		
	}
	return dataMap;
}
%>