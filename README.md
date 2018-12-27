# MacDetect
A simple Mac-Address Sniffer based on tshark

<b>Requirements</b>

Requires tshark to be installed, type ```sudo apt install tshark``` if you are running an Ubuntu Machine.


<b>Start the Observer</b>

To start the observer you will need to cd into the cloned Folder on your Machine and pass a Wifi Monitoring Device as first Parameter. The setup your Monitoring Device the easy way, you could use airmon-ng. See https://www.aircrack-ng.org/ for more information on that.
<b>Example: </b>

```./macDetect.sh wlan0mon```

<b>Add known Devices</b>

In the top-section of macDetect.sh you are able to insert further Mac-Adresses associated to Names you give them.
These Names will then be shown in the first column of the output table.

<b>Example:</b>

```knownDevices["00:00:00:00:00:00"]="My Smartphone"```


Feel free to Contact me on Problems or Suggestions ;)
