import com.ericsson.otp.erlang.*;

public class EchoServer {
  public static void main(String[] args) throws Exception {
    OtpNode node = new OtpNode("java");         // name the Java node :java
    OtpMbox mbox = new node.createMbox("echo"); // register the inbox as :echo

    while (true) {
      OtpErlangTuple message = (OtpErlangTuple) mbox.receive();
      OtpErlangPid from = (OtpErlangPid) message.elementAt(0);
      OtpErlangObject[] reply = new OtpErlangObject[2];
      reply[0] = mbox.self();
      reply[1] = message.elementAt(1);
      mbox.send(from, new OtpErlangTuple(reply));
    }
  }
}
