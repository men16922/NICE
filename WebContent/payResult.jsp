<%@ page contentType="text/html; charset=euc-kr"%>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.net.URL" %>
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
* <���� ��� �Ķ����>
****************************************************************************************
*/
String authResultCode 	= (String)request.getParameter("AuthResultCode"); 	// ������� : 0000(����)
String authResultMsg 	= (String)request.getParameter("AuthResultMsg"); 	// ������� �޽���
String nextAppURL 		= (String)request.getParameter("NextAppURL"); 		// ���� ��û URL
String txTid 			= (String)request.getParameter("TxTid"); 			// �ŷ� ID
String authToken 		= (String)request.getParameter("AuthToken"); 		// ���� TOKEN
String payMethod 		= (String)request.getParameter("PayMethod"); 		// ��������
String mid 				= (String)request.getParameter("MID"); 				// ���� ���̵�
String moid 			= (String)request.getParameter("Moid"); 			// ���� �ֹ���ȣ
String amt 				= (String)request.getParameter("Amt"); 				// ���� �ݾ�
String reqReserved 		= (String)request.getParameter("ReqReserved"); 		// ���� �����ʵ�
String netCancelURL 	= (String)request.getParameter("NetCancelURL"); 	// ����� ��û URL
//String authSignature = (String)request.getParameter("Signature");			// Nicepay���� ������ ���䰪�� ���Ἲ ���� Data

/*  
****************************************************************************************
* Signature : ��û �����Ϳ� ���� ���Ἲ ������ ���� �����ϴ� �Ķ���ͷ� ���� ���� ��û �� ���� �� ���� ���� �̽��� �߻��� ���� ��Ҹ� �����ϱ� ���� ���� �� ����Ͻñ� �ٶ�� 
* ������ ���� �̻������ ���� �߻��ϴ� �̽��� ����� å���� ���� �����Ͻñ� �ٶ��ϴ�.
****************************************************************************************
 */
DataEncrypt sha256Enc 	= new DataEncrypt();
String merchantKey 		= "EYzu8jGGMfqaDEp76gSckuvnaHHu+bC4opsSN6lHv3b2lurNYkVXrZ7Z1AoqQnXI3eLuaUFyoRNC6FkrzVjceg=="; // ����Ű

//���� ���� Signature = hex(sha256(AuthToken + MID + Amt + MerchantKey)
//String authComparisonSignature = sha256Enc.encrypt(authToken + mid + amt + merchantKey);

/*
****************************************************************************************
* <���� ��� �Ķ���� ����>
* ���������������� ���� ��� �Ķ���� �� �Ϻθ� ���õǾ� ������, 
* �߰������� ����Ͻ� �Ķ���ʹ� �����޴����� �����ϼ���.
****************************************************************************************
*/
String ResultCode 	= ""; String ResultMsg 	= ""; String PayMethod 	= "";
String GoodsName 	= ""; String Amt 		= ""; String TID 		= ""; 
//String Signature = ""; String paySignature = "";

/*
****************************************************************************************
* <���� ��� ������ ���� ����>
****************************************************************************************
*/
String resultJsonStr = "";
//���� �������� ���� Signature ������ ���� ���Ἲ ������ �����Ͽ��� �մϴ�.
if(authResultCode.equals("0000") /*&& authSignature.equals(authComparisonSignature)*/){
	/*
	****************************************************************************************
	* <�ؽ���ȣȭ> (�������� ������)
	* SHA-256 �ؽ���ȣȭ�� �ŷ� �������� �������� ����Դϴ�. 
	****************************************************************************************
	*/
	String ediDate			= getyyyyMMddHHmmss();
	String signData 		= sha256Enc.encrypt(authToken + mid + amt + ediDate + merchantKey);

	/*
	****************************************************************************************
	* <���� ��û>
	* ���ο� �ʿ��� ������ ���� �� server to server ����� ���� ���� ó�� �մϴ�.
	****************************************************************************************
	*/
	StringBuffer requestData = new StringBuffer();
	requestData.append("TID=").append(txTid).append("&");
	requestData.append("AuthToken=").append(authToken).append("&");
	requestData.append("MID=").append(mid).append("&");
	requestData.append("Amt=").append(amt).append("&");
	requestData.append("EdiDate=").append(ediDate).append("&");
	requestData.append("SignData=").append(signData);

	resultJsonStr = connectToServer(requestData.toString(), nextAppURL);

	HashMap resultData = new HashMap();
	boolean paySuccess = false;
	if("9999".equals(resultJsonStr)){
		/*
		*************************************************************************************
		* <����� ��û>
		* ���� ����߿� Exception �߻��� ����� ó���� �ǰ��մϴ�.
		*************************************************************************************
		*/
		StringBuffer netCancelData = new StringBuffer();
		requestData.append("&").append("NetCancel=").append("1");
		String cancelResultJsonStr = connectToServer(requestData.toString(), netCancelURL);
		
		HashMap cancelResultData = jsonStringToHashMap(cancelResultJsonStr);
		ResultCode = (String)cancelResultData.get("ResultCode");
		ResultMsg = (String)cancelResultData.get("ResultMsg");
		/*Signature = (String)cancelResultData.get("Signature");
		String CancelAmt = (String)cancelResultData.get("CancelAmt");
		paySignature = sha256Enc.encrypt(TID + mid + CancelAmt + merchantKey);*/
	}else{
		resultData = jsonStringToHashMap(resultJsonStr);
		ResultCode 	= (String)resultData.get("ResultCode");	// ����ڵ� (���� ����ڵ�:3001)
		ResultMsg 	= (String)resultData.get("ResultMsg");	// ����޽���
		PayMethod 	= (String)resultData.get("PayMethod");	// ��������
		GoodsName   = (String)resultData.get("GoodsName");	// ��ǰ��
		Amt       	= (String)resultData.get("Amt");		// ���� �ݾ�
		TID       	= (String)resultData.get("TID");		// �ŷ���ȣ
		/*Signature = (String)resultData.get("Signature");
		paySignature = sha256Enc.encrypt(TID + mid + Amt + merchantKey);*/

		/*
		*************************************************************************************
		* <���� ���� ���� Ȯ��>
		*************************************************************************************
		*/
		if(PayMethod != null){
			if(PayMethod.equals("CARD")){
				if(ResultCode.equals("3001")) paySuccess = true; // �ſ�ī��(���� ����ڵ�:3001)       	
			}else if(PayMethod.equals("BANK")){
				if(ResultCode.equals("4000")) paySuccess = true; // ������ü(���� ����ڵ�:4000)	
			}else if(PayMethod.equals("CELLPHONE")){
				if(ResultCode.equals("A000")) paySuccess = true; // �޴���(���� ����ڵ�:A000)	
			}else if(PayMethod.equals("VBANK")){
				if(ResultCode.equals("4100")) paySuccess = true; // �������(���� ����ڵ�:4100)
			}else if(PayMethod.equals("SSG_BANK")){
				if(ResultCode.equals("0000")) paySuccess = true; // SSG�������(���� ����ڵ�:0000)
			}else if(PayMethod.equals("CMS_BANK")){
				if(ResultCode.equals("0000")) paySuccess = true; // ���°������(���� ����ڵ�:0000)
			}
		}
	}
}else /*if(authSignature.equals(authComparisonSignature))*/{
	ResultCode 	= authResultCode; 	
	ResultMsg 	= authResultMsg;
}/*else{
	System.out.println("���� ���� Signature : " + authSignature);
	System.out.println("���� ���� Signature : " + authComparisonSignature);
}*/
%>
<!DOCTYPE html>
<html>
<head>
<title>NICEPAY PAY RESULT(EUC-KR)</title>
<meta charset="euc-kr">
</head>
<body>
	<table>
		<%if("9999".equals(resultJsonStr)){%>
		<tr>
			<th>���� ��� ���з� ���� ����� ó�� ���� ���</th>
			<td>[<%=ResultCode%>]<%=ResultMsg%></td>
		</tr>
		<%}else{%>
		<tr>
			<th>��� ����</th>
			<td>[<%=ResultCode%>]<%=ResultMsg%></td>
		</tr>
		<tr>
			<th>��������</th>
			<td><%=PayMethod%></td>
		</tr>
		<tr>
			<th>��ǰ��</th>
			<td><%=GoodsName%></td>
		</tr>
		<tr>
			<th>���� �ݾ�</th>
			<td><%=Amt%></td>
		</tr>
		<tr>
			<th>�ŷ� ��ȣ</th>
			<td><%=TID%></td>
		</tr>
		<!--<%/*if(Signature.equals(paySignature)){%>
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
			<td><%=paySignature%></td>
		</tr> -->
		<%}*/}%>
	</table>
	<p>*�׽�Ʈ ���̵��ΰ�� ���� ���� 11�� 30�п� ��ҵ˴ϴ�.</p>
</body>
</html>
<%!
public final synchronized String getyyyyMMddHHmmss(){
	SimpleDateFormat yyyyMMddHHmmss = new SimpleDateFormat("yyyyMMddHHmmss");
	return yyyyMMddHHmmss.format(new Date());
}

// SHA-256 �������� ��ȣȭ
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