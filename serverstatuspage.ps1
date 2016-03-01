#*=============================================================================
#* Clark's Server Status Tool
#*=============================================================================

#*=============================================================================
#* Release Notes
#*=============================================================================
#*
#*
#*=============================================================================

#*=============================================================================
#* Build the header
#*=============================================================================

Function header {
$Prereport =  @'
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Server Status</title>
<link href="css/styles.css" rel="stylesheet" type="text/css" />
<!--[if IE]><link href="css/stylesIE.css" rel="stylesheet" type="text/css" /><![endif]-->
<!--[if !IE 7]><style type="text/css">#wrap {display:table;height:100%}</style><![endif]-->
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
<script type="text/javascript" src="js/expand.js"></script>
<script type="text/javascript">
$(function() {
    $("div.expand").toggler({method: "slideFadeToggle"});    
    $("#content").expandAll({trigger: "div.expand", ref: "div.demo", localLinks: "p.top a"});
});
</script>
</head>
<body>
'@
$Prereport +=  @"
<div id="wrap">
	<div id="main">
        <div id="header">
            <div id="title" class="grid960">
                <div class="leftColumn">
                    <h2 class="floatLeft">Server Status</h2>
                </div>
                <div class="rightColumn">
                    <div id="userOptions">Next update at $($date)</div>
                    <table cellpadding="0" cellspacing="0">
                        <tr><td><input name="" type="text" class="searchField" /></td><td><input type="image" src="images/btnSearch.png" width="75" height="28" alt="Search" class="searchBtn" /></td></tr>
                    </table>
                </div>
             </div>
        </div>
        <div id="content">        
"@
Return $Prereport
}

#*=============================================================================
#* Build the row header
#*=============================================================================
Function rowheader {
$Prereport =  @"
           <div class="grid1240">
            <div class="modulegrouper">
              <div class="expand"><h2>$location</h2></div>
                  <div class="collapse">
                       <div class="grouper">
                          <div class="$($rowtype)">
"@
Return $Prereport
}

#*=============================================================================
#* Build the footer
#*=============================================================================
Function footer {
$Prereport = @"
</div>
</div>
</div>
</div>
    </div>
<div id="footer">
    <div class="grid960">
        <div class="leftColumn">
            <span class="copyright">Copyright &copy; 2016 Your Company</span>
        </div>
        <div class="rightColumn">
            <h3>Best Office Ever</h3>
            <p class="address">1340 Somewhere<br />
            Over, The rainbow</p>
            <p class="contact"><strong>Phone:</strong> (000) 000-0000<br />
            <strong>Fax:</strong> (000) 000-0000</p>
        </div>
    </div>
</div>
</body>
</html>
"@
Return $Prereport
}

#*=============================================================================
#* Save output to file
#*=============================================================================
Function save{
$Filename = "index.htm"
$Finalreport | out-file -encoding ASCII -filepath $Filename
Write "Audit saved as $Filename"
}

#*=============================================================================
#* Collate data for target
#*=============================================================================
Function gettargetdata {

}

#*=============================================================================
#* Format body for target group
#*=============================================================================
Function body {
$Prereport =  @"
"@
Foreach ($Target in $Targets){
        $netinfo = ""
        $lastuser =  ""
    	$colShares =  ""
    	$wmi =  ""
        $localdatetime =  ""
        $lastbootuptime =  ""
        $uptime =  ""
        $days= ""
        $hours= ""
        $mins= ""
    	$OperatingSystems =  ""
    	$BootINI =  ""
        $colDisks =  ""
        $LBTime= ""       
        $NICCount =  ""
        $colAdapters =  ""
    $ComputerSystem = $null
    $ComputerSystem = Get-WmiObject -computername $Target Win32_ComputerSystem
    if ($ComputerSystem -ne $null) {
        $fontcolor = "Green"
    	switch ($ComputerSystem.DomainRole){
    		0 { $ComputerRole = "Standalone Workstation" }
    		1 { $ComputerRole = "Member Workstation" }
    		2 { $ComputerRole = "Standalone Server" }
    		3 { $ComputerRole = "Member Server" }
    		4 { $ComputerRole = "Domain Controller" }
    		5 { $ComputerRole = "Domain Controller" }
    		default { $ComputerRole = "Information not available" }
	    }
    	#$colLogFiles = Get-WmiObject -ComputerName $Target Win32_NTEventLogFile
    	#$WmidtQueryDT = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime([DateTime]::Now.AddDays(-1))
    	#$colLoggedEvents = Get-WmiObject -computer $Target -query ("Select * from Win32_NTLogEvent Where Type='Error' and TimeWritten >='" + $WmidtQueryDT + "'")
    	#$WmidtQueryDT = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime([DateTime]::Now.AddDays(-1))
    	#$colLoggedEvents = Get-WmiObject -computer $Target -query ("Select * from Win32_NTLogEvent Where Type='Warning' and TimeWritten >='" + $WmidtQueryDT + "'")
        $netinfo = GWMI -cl "Win32_NetworkAdapterConfiguration" -name "root\CimV2" -comp $target -filter "IpEnabled = TRUE"
        $lastuser = Get-WmiObject Win32_NetworkLoginProfile -ComputerName $target | Sort -descending Date | Select * -First 1 | Select Name
    	$colShares = Get-wmiobject -ComputerName $Target Win32_Share
    	$wmi = gwmi Win32_OperatingSystem -EA silentlycontinue -ComputerName $Target
        $localdatetime = $wmi.ConvertToDateTime($wmi.LocalDateTime)
        $lastbootuptime = $wmi.ConvertToDateTime($wmi.LastBootUpTime)
        $uptime = $localdatetime - $lastbootuptime
        $days=$uptime.Days
        $hours=$uptime.Hours
        $mins=$uptime.Minutes
    	$OperatingSystems = Get-WmiObject -computername $Target Win32_OperatingSystem
    	#$TimeZone = Get-WmiObject -computername $Target Win32_Timezone
    	#$Keyboards = Get-WmiObject -computername $Target Win32_Keyboard
    	#$SchedTasks = Get-WmiObject -computername $Target Win32_ScheduledJob
    	$BootINI = $OperatingSystems.SystemDrive + "boot.ini"
        #$RecoveryOptions = Get-WmiObject -computername $Target Win32_OSRecoveryConfiguration
        $colDisks = Get-WmiObject -ComputerName $Target Win32_LogicalDisk
        $LBTime=$OperatingSystems.ConvertToDateTime($OperatingSystems.Lastbootuptime)
        $NICCount = 0
        $colAdapters = Get-WmiObject -ComputerName $Target Win32_NetworkAdapterConfiguration
        #$colInstalledPrinters =  Get-WmiObject -ComputerName $Target Win32_Printer
        #Write-Output "..Services"
        #$colListOfServices = Get-WmiObject -ComputerName $Target Win32_Service
    	switch ($ComputerRole){
    		"Member Workstation" { $CompType = "Computer Domain"; break }
    		"Domain Controller" { $CompType = "Computer Domain"; break }
    		"Member Server" { $CompType = "Computer Domain"; break }
    		default { $CompType = "Computer Workgroup"; break }
    	   }
    }
    else{
$fontcolor = "Red"
    }
$Prereport +=  @"
                                 <div class="module">
                        	      <h3><font color="$fontcolor">$Target</font></h3>
                                           <div class="expand">
                                            <table>
                                                <tr>
                                                  	<th><b>Up Time</b></th>
                                                  	<td>$days days $hours hours $mins mins</td>
                                                </tr>
                                                <tr>
                                                  	<th><b>Last Logged In User</b></th>
                                                  	<td>$($lastuser.Name)</td>
                                                </tr> 
                    							<tr>
                    								<th><b>IP / MAC Address</b></th>
                    								<td>$($netinfo.IpAddress)/$($netinfo.MACAddress)</td>
                    							</tr>
                                                <tr>
                                                   	<th><b>Operating System</b></th>
                                                   	<td>$($OperatingSystems.Caption)</td>
                                                </tr>
                                                <tr>
                                                   	<th><b>Service Pack</b></th>
                                                   	<td>$($OperatingSystems.CSDVersion)</td>
                                                </tr>
"@
		Foreach ($objDisk in $colDisks)
		{
			if ($objDisk.DriveType -eq 3)
			{
                if ($OperatingSystems.SystemDrive -eq $objDisk.DeviceID)
                {
            $freespace = [math]::round(($objDisk.FreeSpace / 1048576))
$Prereport +=  @"
                                                <tr>
                                            		<th ><b>Free Space on $($objDisk.DeviceID)</b></th>
							                        <td>$Freespace MB</td>
                       	                        </tr>
"@
        	   }
            }
        }

$Prereport += @"      

                                            	<tr>
                                            		<th ><b>Model</b></th>
                                            		<td >$($ComputerSystem.Model)</td>
                                            	</tr>
                                            	<tr>
                                            		<th ><b>Number of Processors</b></th>
                                            		<td >$($ComputerSystem.NumberOfProcessors)</td>
                                            	</tr>
                                            	<tr>
                                            		<th ><b>Memory</b></th>
"@
		Foreach ($objDisk in $colDisks)
		{
			if ($objDisk.DriveType -eq 3)
			{
            if ($OperatingSystems.SystemDrive -eq $objDisk.DeviceID)
            {
			$memoryinmb = [math]::round(($ComputerSystem.TotalPhysicalMemory / 1048576))
$Prereport += @"            
                			 						<td>$memoryinmb MB</td>
                                                </tr>
"@                            	
        	}
            }
        }
$Prereport += @"                                      
                                            	<tr>
                                            	<th ><b>Last System Boot</b></th>
                                            		<td >$($LBTime)</td>
                                            	</tr> 
"@
            if ($fontcolor -eq "Red")
			{
$Prereport += @"             
                                     <div class=errorfiller></div>
"@              
			}
$Prereport += @"                                                                            	
                                    	   </table>
                                    </div>
                           <div class="collapse">
                                <div class=filler></div>
                                    <h3>Drives</h3>
                                      <div class=container>
				                       <div class=tableDetail>                   
                    				    <table>
                    						<tr>
                    	  						<th><b>Drive Letter</b></th>
                    	  						<th><b>Label</b></th>
                    	  						<th><b>File System</b></th>
                    	  						<th><b>Disk Size</b></th>
                    	  						<th><b>Disk Free Space</b></th>
                    	  						<th><b>% Free Space</b></th>
                    	  					</tr>
"@

	Foreach ($objDisk in $colDisks)
	{
		if ($objDisk.DriveType -eq 3)
		{
        $disksize = [math]::round(($objDisk.size / 1048576))
		$freespace = [math]::round(($objDisk.FreeSpace / 1048576))
		$percFreespace=[math]::round(((($objDisk.FreeSpace / 1048576)/($objDisk.Size / 1048676)) * 100),0)
$Prereport += @" 			
                        					<tr>
            									<td>$($objDisk.DeviceID)</td>
            			 						<td>$($objDisk.VolumeName)</td>
            			 						<td>$($objDisk.FileSystem)</td>
            			 						<td>$disksize MB</td>
            			 						<td>$Freespace MB</td>
            			 						<td>$percFreespace%</td>
            								</tr>
"@            
		}
	}
$Prereport+= @"
                    	               </table>
                                    </div>
                                  </div>
                             <div class=filler></div>
                                 <h3>Shares</h3>
                                      <div class=container>
				                       <div class=tableDetail>                                 
                            			<table>
                    						<tr>
                    	  						<th><b>Share</b></th>
                    	  						<th><b>Path</b></th>
                    	  						<th><b>Comment</b></th>
                    						</tr>
"@
Foreach ($objShare in $colShares)
	{
$Prereport+= @"
                							<tr>
                								<td>$($objShare.Name)</td>
                								<td>$($objShare.Path)</td>
                								<td>$($objShare.Caption)</td>
                							</tr>
"@
	}	
$Prereport+= @"
    					               </table>
                            		  </div>
                                    </div>
                            	</div>             
                                <div> 
                                <div class=filler></div>                   
                            <a href="http://tiger/default.aspx?item=compdetail&comp=167&title=$target">Go to $target on LanSweeper &rarr;</a>
                        </div>
                    </div>   
"@
}
Return $Prereport
}

Function groupfooter {
$Prereport = @"
                <br clear="all" />
            </div>
        </div>
	</div>    
</div>
</div>
<DIV class=filler></DIV>  
"@ 
Return $Prereport
}        

#*=============================================================================
#* Main functions
#*=============================================================================

$date = (get-date).AddSeconds(-190)
#call header
$Finalreport = header
#call targets and location
$location = "Somewhere"
$targets = "Server1","Server2"
$rowtype = "row first"
#call rowheader
$Finalreport += rowheader
#call body
$Finalreport += body

$Finalreport += groupfooter

#call targets and location
$location = "Somewhere else"
$Targets = "Server3", "Server4"
$rowtype = "row"
#call rowheader
$Finalreport += rowheader
#call body
$Finalreport += body

$Finalreport += groupfooter

$Finalreport += footer
#call save
save
