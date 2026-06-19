L.ui.view.extend({

    title: L.tr('App Health Status'),
    description: L.tr(''),

    MiscUtilGetUCISections: L.rpc.declare({
        object: 'uci',
        method: 'get',
        params: [ 'config', 'type'],
        expect: { values: {} }
    }),
    
    MiscUtilRunDiagnostic: L.rpc.declare({
        object: 'rpc-applicationoverview',
        method: 'run',
        params: [ 'utility', 'action','section','usrinputs' ]
    }),
    
    MiscUtilFileRead: L.rpc.declare({
        object: 'file',
        method: 'read',
        params: [ 'path' ]
    }),

    MiscUtilRestartApp: L.rpc.declare({
        object: 'luci2.system',
        method: 'init_action',
        params: [ 'name', 'action' ]
    }),
    
    MiscUtilRunUtility : function(ev)
    {
        var self = ev.data.self;
        var UtilityWithAction = ev.data.evActionData;
        var idval1,idval2,idval3;
        
        if (UtilityWithAction.utility == "System Applications") {
            var id=$("#Input1"+"_"+UtilityWithAction['.name']+"_"+UtilityWithAction.action);
            AppName=id.val();
            
            if(AppName== "" || typeof(AppName)==="undefined")
            {
                alert("Invalid user entry.");
            }
            else
            {
                L.ui.loading(true);
                self.MiscUtilRestartApp(AppName,"restart").then(function(rv)
                {
                    L.ui.loading(false);
                    if(typeof(rv)==="undefined")
                    {
                        var ErrorMsg="Failed on "+AppName+"application  restart.";
                        $('#misc_utility_output').empty().show();
                        $('#misc_utility_output').append(ErrorMsg);
                        
                        $('html, body').animate({
                            scrollTop: $("#misc_utility_output").offset().top
                        }, 2000);
                    }
                    else
                    {
                        $('#misc_utility_output').empty().show();
                        $('#misc_utility_output').append("restarted application");
                       
                        $('html, body').animate({
                            scrollTop: $("#misc_utility_output").offset().top
                        }, 2000);
                    }
                }); 
            }
        }
        else if (UtilityWithAction.utility == "Read LogFiles") 
        {
            var id=$("#Input1"+"_"+UtilityWithAction['.name']+"_"+UtilityWithAction.action);
            idval1=id.val();
            
            var evFileName=idval1+"File";
            var FileName=UtilityWithAction[evFileName];
            if(idval1== "" || typeof(idval1)==="undefined")
            {
                alert("Invalid user entry.");
            }
            else
            {
                L.ui.loading(true);
               
                self.MiscUtilFileRead(FileName).then(function(rv)
                {
					
                    L.ui.loading(false);
                    // alert(filename);
                    if(typeof(rv)==="undefined")
                    {
                        var ErrorMsg="There is no log entry for the "+idval1+".";
                        $('#misc_utility_output').empty().show();
                        $('#misc_utility_output').append(ErrorMsg);
                        
                        $('html, body').animate({
                            scrollTop: $("#misc_utility_output").offset().top
                        }, 2000);
                    }
                    else
                    {
                        $('#misc_utility_output').empty().show();
                        $('#misc_utility_output').append(rv.data);
                       
                        $('html, body').animate({
                            scrollTop: $("#misc_utility_output").offset().top
                        }, 2000);
                    }
                }); 
            }
        }
        else if (UtilityWithAction.utility == "Download Files")
        {
            var ID1=$("#Input1"+"_"+UtilityWithAction['.name']+"_"+UtilityWithAction.action);
            var DownloadFile=ID1.val();
            var ID2=$("#Input2"+"_"+UtilityWithAction['.name']+"_"+UtilityWithAction.action);
            var SysTable=ID2.val();
            var evDatabaseName=DownloadFile+"Database";
            var SysDatabase=UtilityWithAction[evDatabaseName];
            var SectionID=UtilityWithAction['.name'];
            
            if(DownloadFile=="Calibration")
            {
                if(SysTable=="")
                {
                    alert("Please enter the table name");
                    return;
                }
            }
           
            var Form=$('<form />')
                .attr("action","/cgi-bin/file-download")
                .attr("method", "post")
                .attr("id","file_download")
                .attr("style","display:inline");
            
            var ButtonGroup=$('<div />')
                .attr("class","btn-group btn-group-sm")
                .attr("id","DDBbtngroup");
            
            var SessionId=$('<input />')
                .attr('type', 'hidden')
                .attr('name','sessionid')
                .val(L.globals.sid);
            
            var DownloadFileID=$('<input />')
                .attr('type', 'hidden')
                .attr('name','DownloadFile')
                .val(DownloadFile);
                        
            var SysDatabaseID=$('<input />')
                .attr('type', 'hidden')
                .attr('name','SysDatabase')
                .val(SysDatabase);
            
            var SysTableID=$('<input />')
                .attr('type', 'hidden')
                .attr('name','SysTable')
                .val(SysTable);
            
            var ConfigSectionId=$('<input />')
                .attr('type', 'hidden')
                .attr('name','SectionID')
                .val(SectionID);
            
            if($('#file_download').length == 0)
            {
                $('button:contains("DOWNLOAD")')
                    .closest("div")
                    .removeClass("btn-group btn-group-sm");
                $('button:contains("DOWNLOAD")').wrap(Form);
                $('button:contains("DOWNLOAD")').wrap(ButtonGroup);
                $('#DDBbtngroup').append(SessionId);
                $('#DDBbtngroup').append(DownloadFileID);
                $('#DDBbtngroup').append(SysDatabaseID);
                $('#DDBbtngroup').append(SysTableID);
                $('#DDBbtngroup').append(ConfigSectionId);
                $('#file_download').submit();
            }
            else
            {
                $("input[name='sessionid']").val(L.globals.sid);
                $("input[name='DownloadFile']").val(DownloadFile);
                $("input[name='SysDatabase']").val(SysDatabase);
                $("input[name='SysTable']").val(SysTable);
                $("input[name='SectionID']").val(SectionID);
                $('#file_download').submit();
            }
        }
        else 
        {
            if(UtilityWithAction.inputs >= 1)
            {
                var id=$("#Input1"+"_"+UtilityWithAction['.name']+"_"+UtilityWithAction.action);
                idval1=id.val();
            }
    
            if(UtilityWithAction.inputs >= 2)
            {
                var id=$("#Input2"+"_"+UtilityWithAction['.name']+"_"+UtilityWithAction.action);
                idval2=id.val();
            }
    
            if(UtilityWithAction.inputs >= 3)
            {
                var id=$("#Input3"+"_"+UtilityWithAction['.name']+"_"+UtilityWithAction.action);
                idval3=id.val();
            }

            var Utility = UtilityWithAction.utility;
            var Action = UtilityWithAction.action;
            var SectionName = UtilityWithAction['.name'];
            var UserEntry = {"input1":idval1,"input2":idval2,"input3":idval3};
            
            L.ui.loading(true);
            self.MiscUtilRunDiagnostic(Utility,Action,SectionName,UserEntry).then(function (rv)
            {
                L.ui.loading(false);
                
                $('#misc_utility_output').empty().show();
                $('#misc_utility_output').append(rv.output);
                
                $('html, body').animate({
                    scrollTop: $("#misc_utility_output").offset().top
                }, 2000);
            });
        }
    },

    MiscUtilRenderContents : function(rv)
    {
        var self = this;
        
        var list = new L.ui.table({
            columns: [{
                caption: L.tr('Utility'),
                width:'25%',
                align: 'left',
                format: function(v,n) {
                    var div = $('<p />').attr('id', 'MiscUtilName_%s'.format(n));
                    return div.append('<strong>'+v+'</strong>');
                }
            },{
                caption: L.tr('Input'),
                width:'50%',
                align: 'left',
                format: function(CfgObj,n) {

                    var InputMainDiv=$('<div/>')
                        .addClass('row');
                        
                    if (CfgObj.inputs >= 1)
                    {
                        var Input1SubDiv=$('<div/>')
                                .addClass('col-lg-4');

                        var Input1Element = '';

                        if (CfgObj.input1Element == "text")
                        {
                            Input1Element = $('<input />')
                                .addClass('form-control')
                                .attr('id', "Input1"+"_"+CfgObj['.name']+"_"+CfgObj.action)
                                .attr('type', 'text')
                                .attr('placeholder',CfgObj.input1Name);

                            Input1SubDiv.append(Input1Element);
                        }
                        else if (CfgObj.input1Element == "selection")
                        {
                            Input1Element = $('<select />')
                                .addClass('form-control')
                                .attr('id', "Input1"+"_"+CfgObj['.name']+"_"+CfgObj.action);

                            Input1SubDiv.append(Input1Element);

                            var input1options='';
                            input1options+='<option value="">'+CfgObj.input1Name+'</option>';
                            if (CfgObj.input1Type == "integer")
                            {
                                if(typeof(CfgObj.input1ExtraValues) !== "undefined")
                                {
                                    var input1ExtraValues=CfgObj.input1ExtraValues;

                                    for(var i=0; i < input1ExtraValues.length; i++)
                                    {
                                        input1options+='<option value="'+input1ExtraValues[i]+'">'+input1ExtraValues[i]+'</option>';
                                    }
                                }
                                for(var i=CfgObj.input1MinRange; i <= CfgObj.input1MaxRange; i++)
                                {
                                    input1options+='<option value="'+i+'">'+i+'</option>';
                                }
                            }
                            else if (CfgObj.input1Type == "string")
                            {
                                var input1Values = CfgObj.input1Values;
                                for(var i = 0; i < input1Values.length; i++)
                                {
                                    input1options+='<option value="'+input1Values[i]+'">'+input1Values[i]+'</option>';
                                }
                            }
                            Input1Element.append(input1options);
                        }
                        else if (CfgObj.input1Element == "DateTime")
                        {
                            var Input1SubDiv=$('<div/>');
                                    
                            Input1Element = $('<input />')
                                .addClass('form-control date-class')
                                .attr('id', "Input1"+"_"+CfgObj['.name']+"_"+CfgObj.action)
                                .attr('data-custom-class', 'form-control')
                                .attr('type', 'text')
                                .attr('class','DateVal')
                                .attr('data-format', 'YYYY-MM-DD HH:mm:ss')
                                .attr('data-template', 'DD-MM-YYYY HH:mm:ss');

                            Input1SubDiv.append(Input1Element);
                            $(InputMainDiv).removeClass("row");
                        }

                        if (CfgObj.inputs == 1 )
                        {
                            return InputMainDiv.append(Input1SubDiv);
                        }
                        else
                        {
                            InputMainDiv.append(Input1SubDiv);
                        }
                    }

                    if (CfgObj.inputs >= 2)
                    {
                        var Input2SubDiv=$('<div/>')
                            .addClass('col-lg-4');

                        var Input2Element = '';
                       
                        if (CfgObj.input2Element == "text")
                        {
                            Input2Element = $('<input />')
                                .addClass('form-control')
                                .attr('id', "Input2"+"_"+CfgObj['.name']+"_"+CfgObj.action)
                                .attr('type', 'text')
                                .attr('placeholder',CfgObj.input2Name);

                            Input2SubDiv.append(Input2Element);
                        }
                        else if (CfgObj.input2Element == "selection")
                        {
                            Input2Element = $('<select />')
                                .addClass('form-control')
                                .attr('id', "Input2"+"_"+CfgObj['.name']+"_"+CfgObj.action);

                            Input2SubDiv.append(Input2Element);

                            var input2options='';
                             input2options+='<option value="">'+CfgObj.input2Name+'</option>';
                            if (CfgObj.input2Type == "integer" )
                            {
                                if(typeof(CfgObj.input2ExtraValues) !== "undefined")
                                {
                                    var input2ExtraValues=CfgObj.input2ExtraValues;

                                    for(var i=0; i < input2ExtraValues.length; i++)
                                    {
                                        input2options+='<option value="'+input2ExtraValues[i]+'">'+input2ExtraValues[i]+'</option>';
                                    }
                                }
                                
                                for(var i=CfgObj.input2MinRange; i <= CfgObj.input2MaxRange; i++)
                                {
                                    input2options+='<option value="'+i+'">'+i+'</option>';
                                }
                            }
                            else if (CfgObj.input2Type == "string")
                            {
                                var input2Values = CfgObj.input2Values;
                                
                                for(var i = 0; i < input2Values.length; i++)
                                {
                                    input2options+='<option value="'+input2Values[i]+'">'+input2Values[i]+'</option>';
                                }
                            }
                            Input2Element.append(input2options);
                        }
                        else if (CfgObj.input2Element == "DateTime")
                        {
                            var Input2SubDiv=$('<div/>');

                            Input2Element = $('<input />')
                                .addClass('form-control date-class')
                                .attr('id', "Input2"+"_"+CfgObj['.name']+"_"+CfgObj.action)
                                .attr('data-custom-class', 'form-control')
                                .attr('type', 'text')
                                .attr('class','DateVal')
                                .attr('data-format', 'YYYY-MM-DD HH:mm:ss')
                                .attr('data-template', 'DD-MM-YYYY HH:mm:ss');

                            Input2SubDiv.append(Input2Element);
                            $(InputMainDiv).removeClass("row");
                        }

                        if (CfgObj.inputs == 2 )
                        {
                            return InputMainDiv.append(Input2SubDiv);
                        }
                        else
                        {
                            InputMainDiv.append(Input2SubDiv);
                        }
                    }

                    if (CfgObj.inputs >= 3)
                    {
                        var Input3SubDiv=$('<div/>')
                            .addClass('col-lg-4');

                        var Input3Element = '';

                        if (CfgObj.input3Element == "text")
                        {
                            Input3Element = $('<input />')
                                .addClass('form-control')
                                .attr('id', "Input3"+"_"+CfgObj['.name']+"_"+CfgObj.action)
                                .attr('type', 'text')
                                .attr('placeholder',CfgObj.input3Name);

                            Input3SubDiv.append(Input3Element);
                        }
                        else if (CfgObj.input3Element == "selection")
                        {
                            Input3Element = $('<select />')
                                .addClass('form-control')
                                .attr('id', "Input3"+"_"+CfgObj['.name']+"_"+CfgObj.action);

                            Input3SubDiv.append(Input3Element);

                            var input3options='';
                            input3options+='<option value="">'+CfgObj.input3Name+'</option>';
                            if (CfgObj.input3Type == "integer" )
                            {
                                if(typeof(CfgObj.input3ExtraValues) !== "undefined")
                                {
                                    var input3ExtraValues=CfgObj.input3ExtraValues;

                                    for(var i=0; i < input3ExtraValues.length; i++)
                                    {
                                        input3options+='<option value="'+input3ExtraValues[i]+'">'+input3ExtraValues[i]+'</option>';
                                    }
                                }
                                for(var i=CfgObj.input3MinRange; i <= CfgObj.input3MaxRange; i++)
                                {
                                    input3options+='<option value="'+i+'">'+i+'</option>';
                                }
                            }
                            else if (CfgObj.input3Type == "string")
                            {
                                var input3Values = CfgObj.input3Values;
                                for(var i = 0; i < input3Values.length; i++)
                                {
                                    input3options+='<option value="'+input3Values[i]+'">'+input3Values[i]+'</option>';
                                }
                            }
                            Input3Element.append(input3options);
                        }
                        else if (CfgObj.input3Element == "DateTime")
                        {
                            var Input3SubDiv=$('<div/>');

                            Input3Element = $('<input />')
                                .addClass('form-control date-class')
                                .attr('id', "Input3"+"_"+CfgObj['.name']+"_"+CfgObj.action)
                                .attr('data-custom-class', 'form-control')
                                .attr('type', 'text')
                                .attr('class','DateVal')
                                .attr('data-format', 'YYYY-MM-DD HH:mm:ss')
                                .attr('data-template', 'DD-MM-YYYY HH:mm:ss');

                            Input3SubDiv.append(Input3Element);
                            $(InputMainDiv).removeClass("row");
                        }
                        return InputMainDiv.append(Input3SubDiv);
                    }
                }
            },
            {
                caption: L.tr('Action'),
                width:'25%',
                align: 'left',
                format: function(ActionData, n) {
                    var action = ActionData.action;
                    
                    return $('<div />')
                    .addClass('btn-group btn-group-sm')
                    .append(L.ui.button(L.tr(action),'default', L.tr('Run'))
                    .css('width','100px')
                    .click({self: self, evActionData: ActionData}, self.MiscUtilRunUtility));
                }
            }]
        });
        
        for (var key in rv)
        {
            if (rv.hasOwnProperty(key))
            {
                var obj = rv[key];
                var utility = obj.utility;
                list.row([utility,obj,obj]);
            }
        }
        
        $('#map').
            append(list.render());
            
        $('.DateVal').combodate({
            value: new Date(),
            minuteStep:1
        });
       
        for(var key in rv)
        {
            if(rv.hasOwnProperty(key))
            {
                var obj=rv[key];
                var action=obj.action;
                
                if(action=="DOWNLOAD")
                {
                    var CalibrationID1="#Input1_"+obj['.name']+"_DOWNLOAD";
                    var CalibrationID2="#Input2_"+obj['.name']+"_DOWNLOAD";
                    
                    $(CalibrationID2).hide();
                    $(CalibrationID1).on('change', function() {
                        if($(this).val()=="Calibration")
                        {
                            $(CalibrationID2).show();
                        }
                        else
                        {
                            $(CalibrationID2).hide();
                        } 
                    });
                }
                if(action=="VIEW")
                {
                    var ViewID1="#Input1_"+obj['.name']+"_VIEW";
                    var ViewID2="#Input2_"+obj['.name']+"_VIEW";
                    
                    $(ViewID2).hide();
                    $(ViewID1).on('change', function() {
                        if($(this).val()=="Calibration")
                        {
                            $(ViewID2).show();
                        }
                        else
                        {
                            $(ViewID2).hide();
                        } 
                    });
                }
            }
        }
    },

    execute:function()
    {
        var self = this;
        self.MiscUtilGetUCISections("applist_config","command").then(function(rv){
            for(var key in rv)
            {
                //if(rv.hasOwnProperty(key))
                //{
                    //var obj=rv[key];
                    //var AppStatus=obj.running;
                    //if (AppStatus != 0)
                    //{
                        //var ErrorMsg="Please stop the applications before running the diagnostic utilities";
                        //$("#misc_utility_output").empty().show();
                        //$("#misc_utility_output").append(ErrorMsg);
                    //}
                    //else
                    //{
                        self.MiscUtilGetUCISections("applicationoverviewconfig","applicationoverviewconfig").then(function(rv){
                            self.MiscUtilRenderContents(rv);
                        });
                    }
                //}
            //}
        }); 
    }
});
