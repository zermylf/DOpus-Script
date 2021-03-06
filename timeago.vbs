option explicit

' timeago
' Author: qiuqiu

' This is a script for Directory Opus.
' See https://www.gpsoft.com.au/DScripts/redirect.asp?page=scripts for development information.



' Called by Directory Opus to initialize the script
Function OnInit(initData)
	with initData
		.name           = "timeago"
		.version        = "1.0"
		.copyright      = "qiuqiu"
		.desc           = DOpus.strings.get("desc")
		.url            = "https://resource.dopus.com/u/qiuqiu/"
		.default_enable = true
		.min_version    = "12.0"

		with .AddColumn
			.name      = "create_ago"
			.method    = "On_timeago"
			.label     = DOpus.strings.get("CreateAt")
			.justify   = "right"
			.autogroup = true
		end with

		with .AddColumn
			.name      = "modify_ago"
			.method    = "On_timeago"
			.label     = DOpus.strings.get("ModifyAt")
			.justify   = "right"
			.autogroup = true
		end with
	end with
End Function

Function IIf(ByVal Expression, ByVal TruePart, ByVal FalsePart)
    If Expression Then
		If IsObject(TruePart)  Then Set IIf = TruePart  Else IIf = TruePart
	Else
		If IsObject(FalsePart) Then Set IIf = FalsePart Else IIf = FalsePart
	End If
End Function

sub ShowMessageDialog(ByVal message, ByVal buttons,ByVal title, Byval window,  ByVal icon)
    with DOpus.Dlg
        .window  = window
        .message = message
        .title   = title
        .buttons = buttons
        .icon    = icon 'warning, error, info and question
        .Show
    end with
end sub

'PHP Time Ago Function
'https://phppot.com/php/php-time-ago-function/
'https://css-tricks.com/snippets/php/time-ago-function/
' function timeago(ByVal dDate)
' 	dim periods, lengths, diff, ago, agomap, index, Recent

' 	Recent  = Split(DOpus.strings.get("Recent"), ",")
' 	periods = Split(DOpus.strings.get("periods"), ",")
' 	agomap  = Split(DOpus.strings.get("at"), ",")
' 	lengths = array(60, 60, 24, 7, 365.25/7/12, 12)
' 	index   = 0

' 	ago = IIf(dDate > Now(), 1, 0)
' 	diff = Abs(DateDiff("s", dDate, Now()))
	
' 	Do While diff >= lengths(index) And Ubound(periods)
' 		diff = diff / lengths(index)
' 		index = index + 1
' 		if index > UBound(lengths) Then Exit do
' 	Loop
	
' 	diff = int(diff)
	
' 	if LCase(dopus.language) = "english" Then
' 		if diff > 1 Then periods(index) = periods(index) + "s"	
' 	end if
	
' 	timeago = IIf(index, diff & periods(index) & agomap(ago), Recent(ago))
' End Function

Function TimeAgo(Byval Ddate)
	Dim Periods, Lengths, Diff, Ago, AgoMap, Index, Recent
	
	Recent  = Split(Dopus.Strings.Get("Recent"), ",")
	Periods = Split(Dopus.Strings.Get("Periods"), ",")
	Agomap  = Split(Dopus.Strings.Get("At"), ",")
	Lengths = Array(60, 60, 24, 7, 365.25/7/12, 12)
	
	Diff = Abs(Datediff("S", Ddate, Now()))
	If Ddate > Now() Then Ago = 1 Else Ago = 0
	
	For Index = 0 To Ubound(Lengths)
		If Diff >= Lengths(Index) Then
			Diff = Diff / Lengths(Index)
		Else
			Exit For
		End If
	Next
	If Index > 1 Then Diff = Round(Diff, 1) Else Diff = Int(Diff)
	If Index Then TimeAgo = Diff & Periods(Index) & AgoMap(Ago) Else TimeAgo = Recent(Ago)
End Function

Function GetDate(Path, DateType)
	Dim FSO,Item
	Set FSO = CreateObject("Scripting.FileSystemObject")
	If FSO.FileExists(Path) Then
		Set Item = FSO.GetFile(Path)
	ElseIf FSO.FolderExists(Path) Then
		Set Item = FSO.GetFOlder(Path)
	Else
		GetDate = 0
	End If
	If IsObject(Item) then
		Select Case LCase(DateType)
			Case "a"
				GetDate = Item.DateLastAccessed
			Case "c"
				GetDate = Item.DateCreated
			Case "m"
				GetDate = Item.DateLastModified
		End Select
		Set Item = Nothing
	End If
	Set FSO = Nothing
End Function

' Implement the timeago column
Function On_timeago(ColData)
	dim filedate
	select case ColData.col
		case "create_ago"
			filedate = GetDate(ColData.item, "C")'ColData.item.create
		case "modify_ago"
			filedate = GetDate(ColData.item, "M")'ColData.item.modify
	end select
	ColData.sort = DateDiff("s", filedate, Now())
	ColData.value = timeAgo(filedate)
End Function

' Called to display an About dialog for this script
Function OnAboutScript(aboutData)
    'Dopus.Dlg.Request DOpus.strings.get("desc"), "OK", "About", aboutData.window
    ShowMessageDialog DOpus.strings.get("desc"), "OK", "About", aboutData.window, "info"
End Function

==SCRIPT RESOURCES
<resources>
    <resource type = "strings">
        <strings lang = "english">
            <string id = "CreateAt" text = "Create At" />
            <string id = "ModifyAt" text = "Modify At" />
            <string id = "Recent"   text = "just now, right now" />
            <string id = "at"       text = " Ago, Later" />
            <string id = "periods"  text = " second, minute, hour, day, week, month, year" />
            <string id = "desc"     text = "format file create(modify) date with '*** time ago' statement. eg: '3 hours ago'." />
		</strings>
		<strings lang = "chs">
			<string id = "CreateAt" text = "创建于" />
            <string id = "ModifyAt" text = "修改于" />
            <string id = "Recent"   text = "刚刚, 片刻后" />
            <string id = "at"       text = "前,后" />
            <string id = "periods"  text = " 秒, 分钟, 小时, 天, 周, 月, 年" />
            <string id = "desc"     text = "格式化文件创建 (修改) 日期 '** 时间前' 例如:3小时前。" />
        </strings>
    </resource>
</resources>

