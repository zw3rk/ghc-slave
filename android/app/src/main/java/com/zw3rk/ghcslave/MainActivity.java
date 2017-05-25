package com.zw3rk.ghcslave;

import android.content.Context;
import android.net.LocalServerSocket;
import android.net.LocalSocket;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.ScrollView;
import android.widget.TextView;

import com.zw3rk.GHCSlave;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintStream;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

import static com.zw3rk.GHCSlave.pipeStdOutToSocket;
import static com.zw3rk.GHCSlave.startSlave;

public class MainActivity extends AppCompatActivity {

    // work around for...
    // https://code.google.com/p/android/issues/detail?id=167715
    static boolean isReferenceTableLine(final String line) {
        return line.matches("^referenceTable .... length=\\d+ \\d$");
    }
    String startLocalSocketServer(final PrintStream ps) {
        final String socketName = "local.socket.address.listen.native.cmd";
        new Thread() {
            @Override
            public void run() {
                LocalServerSocket server = null;
                try {
                    server = new LocalServerSocket(socketName);
                    LocalSocket receiver = server.accept();
                    if (receiver != null) {
                        InputStream inputStream = receiver.getInputStream();
                        InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                        BufferedReader in = new BufferedReader(inputStreamReader);
                        while(true) {
                            final String line = in.readLine();
                            if(line == null) break;
                            if(isReferenceTableLine(line)) continue;
                            ps.println(line);
                        }
                        in.close();
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }.start();
        return socketName;
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        final WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        final WifiInfo wifiInfo = wifiManager.getConnectionInfo();
        final ByteBuffer byteBuffer = ByteBuffer.allocate(4);
        byteBuffer.order(ByteOrder.LITTLE_ENDIAN);
        byteBuffer.putInt(wifiInfo.getIpAddress());

        TextView ipv4text = (TextView)findViewById(R.id.ipv4);

        try {
            final InetAddress inetAddress = InetAddress.getByAddress(null, byteBuffer.array());
            ipv4text.setText(inetAddress != null ? inetAddress.getHostAddress() : "None");
        } catch (UnknownHostException e) {
            ipv4text.setText("No ip address!");
        }

        final TextView log = (TextView) findViewById(R.id.log);
        final ScrollView scroll = (ScrollView) findViewById(R.id.scroller);

        OutputStream os = new OutputStream() {
            @Override
            public void write(int b) throws IOException {
                final char ch = new Character((char) b);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        log.append(String.valueOf(ch));
                        scroll.fullScroll(View.FOCUS_DOWN);
                    }
                });
            }
        };

        PrintStream ps = new PrintStream(os, true);

        String socketName = startLocalSocketServer(ps /* System.out */);

        pipeStdOutToSocket(socketName);

        GHCSlave c = new GHCSlave();
        startSlave(true, 5000, this.getFilesDir().getAbsolutePath());
    }
}
