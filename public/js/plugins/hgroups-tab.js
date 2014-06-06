/* 
 ** Copyright [2013-2014] [Megam Systems]
 **
 ** Licensed under the Apache License, Version 2.0 (the "License");
 ** you may not use this file except in compliance with the License.
 ** You may obtain a copy of the License at
 **
 ** http://www.apache.org/licenses/LICENSE-2.0
 **
 ** Unless required by applicable law or agreed to in writing, software
 ** distributed under the License is distributed on an "AS IS" BASIS,
 ** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 ** See the License for the specific language governing permissions and
 ** limitations under the License.
 */

var dataTable_hgroups;
var $create_hgroup_dialog;
var $hgroup_quotas_dialog;

var hgroup_acct_graphs = [
    { title : tr("CPU"),
      monitor_resources : "CPU",
      humanize_figures : false
    },
    { title : tr("Memory"),
      monitor_resources : "MEMORY",
      humanize_figures : true
    },
    { title : tr("Net TX"),
      monitor_resources : "NETTX",
      humanize_figures : true
    },
    { title : tr("Net RX"),
      monitor_resources : "NETRX",
      humanize_figures : true
    }
];

function create_hgroup_tmpl(dialog_name){
    return '<div class="row">\
  <div class="large-12 columns">\
    <h3 id="create_hgroup_header">'+tr("Create HGroup")+'</h3>\
    <h3 id="update_hgroup_header">'+tr("Update HGroup")+'</h3>\
  </div>\
</div>\
<div class="reveal-body">\
  <form id="create_hgroup_form" action="">\
    <div class="row">\
      <div class="columns large-5">\
          <label>'+tr("Name")+':\
            <input type="text" name="name" id="name" />\
          </label>\
      </div>\
      <div class="columns large-7">\
          <dl class="tabs right-info-tabs text-center right" data-tab>\
               <dd class="active"><a href="#resource_views"><i class="fa fa-eye"></i><br>'+tr("Views")+'</a></dd>\
               <dd><a href="#resource_providers"><i class="fa fa-cloud"></i><br>'+tr("Resources")+'</a></dd>\
               <dd><a href="#administrators"><i class="fa fa-upload"></i><br>'+tr("Admin")+'</a></dd>\
               <dd><a href="#resource_creation"><i class="fa fa-folder-open"></i><br>'+tr("Permissions")+'</a></dd>\
          </dl>\
      </div>\
    </div>\
    <div class="tabs-content">\
    <div id="resource_views" class="content active">\
      <div class="row">\
        <div class="large-12 columns">\
          <p class="subheader">'
            +tr("Allow users in this hgroup to use the following Sunstone views")+
            '&emsp;<span class="tip">'+tr("Views available to the hgroup users. The default is set in sunstone-views.yaml")+'</span>\
          </p>\
        </div>\
      </div>\
      <div class="row">\
        <div class="large-12 columns">'+
            insert_views(dialog_name)
        +'</div>\
      </div>\
    </div>\
    <div id="resource_providers" class="content">\
        <div class="row">\
          <div class="large-12 columns">\
            <h5>' + tr("Zones") +'</h5>\
          </div>\
        </div>\
        <div class="row">\
          <div class="large-12 columns">\
            <dl class="tabs" id="hgroup_zones_tabs" data-tab></dl>\
            <div class="tabs-content hgroup_zones_tabs_content"></div>\
          </div>\
        </div>\
    </div>\
    <div id="administrators" class=" content">\
      <div class="row">\
        <div class="large-6 columns">\
          <div class="row">\
            <div class="large-12 columns">\
              <label>\
                <input type="checkbox" id="admin_user" name="admin_user" value="YES" />\
                '+tr("Create an administrator user")+'\
                <span class="tip">'+tr("You can create now an administrator user that will be assigned to the new regular hgroup, with the administrator hgroup as a secondary one.")+'</span>\
              </label>\
            </div>\
          </div>' +
          user_creation_div +   // from users-tab.js
        '</div>\
      </div>\
    </div>\
    <div id="resource_creation" class="content">\
        <div class="row">\
          <div class="large-12 columns">\
            <p class="subheader">'
              +tr("Allow users in this hgroup to create the following resources")+
              '&emsp;<span class="tip">'+tr("This will create new ACL Rules to define which virtual resources this hgroup's users will be able to create. You can set different resources for the administrator hgroup, and decide if the administrators will be allowed to create new users.")+'</span>\
            </p>\
          </div>\
        </div>\
        <div class="row">\
          <div class="large-12 columns">\
            <table class="dataTable" style="table-layout:fixed">\
              <thead><tr>\
                <th/>\
                <th>'+tr("VMs")+'</th>\
                <th>'+tr("VNets")+'</th>\
                <th>'+tr("Images")+'</th>\
                <th>'+tr("Templates")+'</th>\
                <th>'+tr("Documents")+'<span class="tip">'+tr("Documents are a special tool used for general purposes, mainly by OneFlow. If you want to enable users of this hgroup to use service composition via OneFlow, let it checked.")+'</span></th>\
              </tr></thead>\
              <tbody>\
                <tr>\
                  <th>'+tr("Users")+'</th>\
                  <td><input type="checkbox" id="hgroup_res_vm" name="hgroup_res_vm" class="resource_cb" value="VM"></input></td>\
                  <td><input type="checkbox" id="hgroup_res_net" name="hgroup_res_net" class="resource_cb" value="NET"></input></td>\
                  <td><input type="checkbox" id="hgroup_res_image" name="hgroup_res_image" class="resource_cb" value="IMAGE"></input></td>\
                  <td><input type="checkbox" id="hgroup_res_template" name="hgroup_res_template" class="resource_cb" value="TEMPLATE"></input></td>\
                  <td><input type="checkbox" id="hgroup_res_document" name="hgroup_res_document" class="resource_cb" value="DOCUMENT"></input></td>\
                  <td/>\
                </tr>\
                <tr>\
                  <th>'+tr("Admins")+'</th>\
                  <td><input type="checkbox" id="hgroup_admin_res_vm" name="hgroup_admin_res_vm" class="resource_cb" value="VM"></input></td>\
                  <td><input type="checkbox" id="hgroup_admin_res_net" name="hgroup_admin_res_net" class="resource_cb" value="NET"></input></td>\
                  <td><input type="checkbox" id="hgroup_admin_res_image" name="hgroup_admin_res_image" class="resource_cb" value="IMAGE"></input></td>\
                  <td><input type="checkbox" id="hgroup_admin_res_template" name="hgroup_admin_res_template" class="resource_cb" value="TEMPLATE"></input></td>\
                  <td><input type="checkbox" id="hgroup_admin_res_document" name="hgroup_admin_res_document" class="resource_cb" value="DOCUMENT"></input></td>\
                </tr>\
              </tbody>\
            </table>\
        </div>\
      </div>\
    </div>\
  </div>\
  <div class="reveal-footer">\
    <div class="form_buttons">\
      <button class="button radius right success" id="create_hgroup_submit" value="HGroup.create">'+tr("Create")+'</button>\
       <button class="button right radius" type="submit" id="update_hgroup_submit">' + tr("Update") + '</button>\
      <button class="button secondary radius" id="create_hgroup_reset_button" type="reset" value="reset">'+tr("Reset")+'</button>\
    </div>\
  </div>\
  <a class="close-reveal-modal">&#215;</a>\
  </form>\
</div>';
}

var hgroup_quotas_tmpl = '<div class="row" class="subheader">\
  <div class="large-12 columns">\
    <h3 id="create_hgroup_quotas_header">'+tr("Update Quota")+'</h3>\
  </div>\
</div>\
<div class="reveal-body">\
<form id="hgroup_quotas_form" action="">quotas_tmpl<div class="reveal-footer">\
    <div class="form_buttons">\
        <button class="button radius right success" id="create_user_submit" type="submit" value="HGroup.set_quota">'+tr("Apply changes")+'</button>\
    </div>\
  </div>\
  <a class="close-reveal-modal">&#215;</a>\
</form>\
</div>';


var hgroup_actions = {
    "HGroup.create" : {
        type: "create",
        call : OpenNebula.HGroup.create,
        callback : function(request, response) {
            // Reset the create wizard
            $create_hgroup_dialog.foundation('reveal', 'close');
            $create_hgroup_dialog.empty();
            setupCreateHGroupDialog();

            OpenNebula.Helper.clear_cache("USER");

            Sunstone.runAction("HGroup.list");
            notifyCustom(tr("HGroup created"), " ID: " + response.HGROUP.ID, false);
        },
        error : onError
    },

    "HGroup.create_dialog" : {
        type: "custom",
        call: popUpCreateHGroupDialog
    },

    "HGroup.list" : {
        type: "list",
        call: OpenNebula.HGroup.list,
        callback: updateHGroupsView,
        error: onError
    },

    "HGroup.show" : {
        type: "single",
        call: OpenNebula.HGroup.show,
        callback:   function(request, response) {
            updateHGroupElement(request, response);
            if (Sunstone.rightInfoVisible($("#hgroups-tab"))) {
                updateHGroupInfo(request, response);
            }
        },
        error: onError
    },

    "HGroup.refresh" : {
        type: "custom",
        call: function() {
          var tab = dataTable_hgroups.parents(".tab");
          if (Sunstone.rightInfoVisible(tab)) {
            Sunstone.runAction("HGroup.show", Sunstone.rightInfoResourceId(tab))
          } else {
            waitingNodes(dataTable_hgroups);
            Sunstone.runAction("HGroup.list", {force: true});
          }
        },
        error: onError
    },

    "HGroup.update_template" : {
        type: "single",
        call: OpenNebula.HGroup.update,
        callback: function(request) {
            Sunstone.runAction('HGroup.show',request.request.data[0][0]);
        },
        error: onError
    },

    "HGroup.update_dialog" : {
        type: "single",
        call: initUpdateHGroupDialog
    },

    "HGroup.show_to_update" : {
        type: "single",
        call: OpenNebula.HGroup.show,
        callback: function(request, response) {
            popUpUpdateHGroupDialog(
                response.HGROUP,
                $create_hgroup_dialog);
        },
        error: onError
    },

    "HGroup.delete" : {
        type: "multiple",
        call : OpenNebula.HGroup.del,
        callback : deleteHGroupElement,
        error : onError,
        elements: hgroupElements
    },

    "HGroup.fetch_quotas" : {
        type: "single",
        call: OpenNebula.HGroup.show,
        callback: function (request,response) {
            var parsed = parseQuotas(response.HGROUP,quotaListItem);
            $('.current_quotas table tbody',$hgroup_quotas_dialog).append(parsed.VM);
            $('.current_quotas table tbody',$hgroup_quotas_dialog).append(parsed.DATASTORE);
            $('.current_quotas table tbody',$hgroup_quotas_dialog).append(parsed.IMAGE);
            $('.current_quotas table tbody',$hgroup_quotas_dialog).append(parsed.NETWORK);
        },
        error: onError
    },

    "HGroup.quotas_dialog" : {
        type: "custom",
        call: popUpHGroupQuotasDialog
    },

    "HGroup.set_quota" : {
        type: "multiple",
        call: OpenNebula.HGroup.set_quota,
        elements: hgroupElements,
        callback: function(request,response) {
            Sunstone.runAction('HGroup.show',request.request.data[0]);
        },
        error: onError
    },

    "HGroup.accounting" : {
        type: "monitor",
        call: OpenNebula.HGroup.accounting,
        callback: function(req,response) {
            var info = req.request.data[0].monitor;
            //plot_graph(response,'#hgroup_acct_tabTab','hgroup_acct_', info);
        },
        error: onError
    },


    "HGroup.add_provider_action" : {
        type: "single",
        call: OpenNebula.HGroup.add_provider,
        callback: function(request) {
           Sunstone.runAction('HGroup.show',request.request.data[0][0]);
        },
        error: onError
    },

    "HGroup.del_provider_action" : {
        type: "single",
        call: OpenNebula.HGroup.del_provider,
        callback: function(request) {
          Sunstone.runAction('HGroup.show',request.request.data[0][0]);
        },
        error: onError
    },

    "HGroup.add_provider" : {
        type: "multiple",
        call: function(params){
            var cluster = params.data.extra_param;
            var hgroup   = params.data.id;

            extra_param = {
                "zone_id" : 0,
                "cluster_id" : cluster
            }

            Sunstone.runAction("HGroup.add_provider_action", hgroup, extra_param);
        },
        callback: function(request) {
            Sunstone.runAction('HGroup.show',request.request.data[0]);
        },
        elements: hgroupElements
    },

    "HGroup.del_provider" : {
        type: "multiple",
        call: function(params){
            var cluster = params.data.extra_param;
            var hgroup   = params.data.id;

            extra_param = {
                "zone_id" : 0,
                "cluster_id" : cluster
            }

            Sunstone.runAction("HGroup.del_provider_action", hgroup, extra_param);
        },
        callback: function(request) {
            Sunstone.runAction('HGroup.show',request.request.data[0]);
        },
        elements: hgroupElements
    }
}

var hgroup_buttons = {
    "HGroup.refresh" : {
        type: "action",
        layout: "refresh",
        alwaysActive: true
    },
//    "Sunstone.toggle_top" : {
//        type: "custom",
//        layout: "top",
//        alwaysActive: true
//    },
    "HGroup.create_dialog" : {
        type: "create_dialog",
        layout: "create",
        condition: mustBeAdmin
    },
  //  "HGroup.update_dialog" : {
   //     type : "action",
    //    layout: "main",
    //    text : tr("Update")
   // },
   // "HGroup.quotas_dialog" : {
    //    type : "action",
    //    text : tr("Quotas"),
      //  layout: "main",
     //   condition: mustBeAdmin
   // },
    "HGroup.delete" : {
        type: "confirm",
        text: tr("Delete"),
        layout: "del",
        condition: mustBeAdmin
    },
};

var hgroup_info_panel = {

};

var hgroups_tab = {
    title: tr("Host Groups"),
    resource: 'HGroup',
    buttons: hgroup_buttons,
    tabClass: 'subTab',
    parentTab: 'infra-tab',
    search_input: '<input id="hgroup_search" type="text" placeholder="'+tr("Search")+'" />',
    list_header: '<i class="fa fa-fw fa-users"></i>&emsp;'+tr("Host Groups"),
    info_header: '<i class="fa fa-fw fa-users"></i>&emsp;'+tr("Host Group"),
    subheader: '<span>\
        <span class="total_hgroups"/> <small>'+tr("TOTAL")+'</small>\
      </span>',
    table: '<table id="datatable_hgroups" class="datatable twelve">\
      <thead>\
        <tr>\
          <th class="check"><input type="checkbox" class="check_all" value=""></input></th>\
          <th>'+tr("ID")+'</th>\
          <th>'+tr("Name")+'</th>\
          <th>'+tr("Hosts")+'</th>\
          <th>'+tr("Cluster")+'</th>\
          <th style="display: none;">'+tr("Memory")+'</th>\
          <th style="display: none;">'+tr("CPU")+'</th>\
        </tr>\
      </thead>\
      <tbody id="tbodyhgroups">\
      </tbody>\
    </table>'
};


Sunstone.addActions(hgroup_actions);
Sunstone.addMainTab('hgroups-tab',hgroups_tab);
Sunstone.addInfoPanel("hgroup_info_panel",hgroup_info_panel);

function insert_views(dialog_name){
  views_checks_str = ""
  var views_array = config['available_views'];
  for (var i = 0; i < views_array.length; i++)
  {
    var checked = views_array[i] == 'cloud' ? "checked" : "";

    views_checks_str = views_checks_str +
             '<input type="checkbox" id="hgroup_view_'+dialog_name+'_'+views_array[i]+
                '" value="'+views_array[i]+'" '+checked+'/>' +
             '<label for="hgroup_view_'+dialog_name+'_'+views_array[i]+'">'+views_array[i]+
             '</label>'
  }
  return views_checks_str;
}

function hgroupElements(){
    return getSelectedNodes(dataTable_hgroups);
}

function hgroupElementArray(hgroup_json){
    var hgroup =hgroup_json.HGROUP;

    var users_str = "0";

    if (hgroup.USERS.ID){
        if ($.isArray(hgroup.USERS.ID)){
            users_str = hgroup.USERS.ID.length;
        } else {
            users_str = "1";
        }
    }

    var vms = "-";
    var memory = "-";
    var cpu = "-";

    if (!$.isEmptyObject(hgroup.VM_QUOTA)){

        var vms = quotaBar(
            hgroup.VM_QUOTA.VM.VMS_USED,
            hgroup.VM_QUOTA.VM.VMS,
            default_hgroup_quotas.VM_QUOTA.VM.VMS);

        var memory = quotaBarMB(
            hgroup.VM_QUOTA.VM.MEMORY_USED,
            hgroup.VM_QUOTA.VM.MEMORY,
            default_hgroup_quotas.VM_QUOTA.VM.MEMORY);

        var cpu = quotaBarFloat(
            hgroup.VM_QUOTA.VM.CPU_USED,
            hgroup.VM_QUOTA.VM.CPU,
            default_hgroup_quotas.VM_QUOTA.VM.CPU);
    }

    return [
        '<input class="check_item" type="checkbox" id="hgroup_'+hgroup.ID+'" name="selected_items" value="'+hgroup.NAME+'"/>',
        hgroup.ID,
        hgroup.NAME,
        hgroup.NOOFHOSTS,
        hgroup.CLUSTER,
        "",
        ""
       // memory,
     //   cpu
    ];
}

function updateHGroupElement(request, hgroup_json){
    var id = hgroup_json.HGROUP.ID;
    var element = hgroupElementArray(hgroup_json);
    updateSingleElement(element,dataTable_hgroups,'#hgroup_'+id);
    //No need to update select as all items are in it always
}

function deleteHGroupElement(request){
    deleteElement(dataTable_hgroups,'#hgroup_'+request.request.data);
}

function addHGroupElement(request,hgroup_json){
    var id = hgroup_json.HGROUP.ID;
    var element = hgroupElementArray(hgroup_json);
    addElement(element,dataTable_hgroups);
}

//updates the list
function updateHGroupsView(request, hgroup_list, quotas_hash){
    hgroup_list_json = hgroup_list;
    var hgroup_list_array = [];

    $.each(hgroup_list,function(){
        // Inject the VM hgroup quota. This info is returned separately in the
        // pool info call, but the hgroupElementArray expects it inside the hGROUP,
        // as it is returned by the individual info call
        var q = quotas_hash[this.HGROUP.ID];

        if (q != undefined) {
            this.HGROUP.VM_QUOTA = q.QUOTAS.VM_QUOTA;
        }

        hgroup_list_array.push(hgroupElementArray(this));
    });
    updateView(hgroup_list_array,dataTable_hgroups);

    // Dashboard info
    $(".total_hgroups").text(hgroup_list.length);
}

function fromJSONtoProvidersTable(hgroup_info){
    providers_array=hgroup_info.RESOURCE_PROVIDER
    var str = ""
    if (!providers_array){ return "";}
    if (!$.isArray(providers_array))
    {
        var tmp_array   = new Array();
        tmp_array[0]    = providers_array;
        providers_array = tmp_array;
    }

    $.each(providers_array, function(index, provider){
       var cluster_id = (provider.CLUSTER_ID == "10") ? tr("All") : provider.CLUSTER_ID;
       str +=
        '<tr>\
            <td>' + provider.ZONE_ID + '</td>\
            <td>' + cluster_id + '</td>\
            <td>\
             <div id="div_minus_rp" class="text-right">\
               <a id="div_minus_rp_a_'+provider.ZONE_ID+'" class="cluster_id_'+cluster_id+' hgroup_id_'+hgroup_info.ID+'" href="#"><i class="fa fa-trash-o"/></a>\
             </div>\
            </td>\
        </tr>';
    });

    $("#div_minus_rp").die();

        // Listener for key,value pair remove action
    $("#div_minus_rp").live("click", function() {
        // Remove div_minus from the id
        zone_id = this.firstElementChild.id.substring(15,this.firstElementChild.id.length);

        var list_of_classes = this.firstElementChild.className.split(" ");

        $.each(list_of_classes, function(index, value) {
            if (value.match(/^cluster_id_/))
            {
              cluster_id=value.substring(11,value.length);
            }
            else
            {
              if (value.match(/^hgroup_id_/))
              {
                hgroup_id=value.substring(9,value.length);
              }
            }

        });

        extra_param = {
            "zone_id" : zone_id,
            "cluster_id" :  (cluster_id == "All") ? 10 : cluster_id
        }

        Sunstone.runAction("HGroup.del_provider_action", hgroup_id, extra_param);
    });

    return str;
}

function updateHGroupInfo(request,hgroup){
    var info = hgroup.HGROUP;

    var info_tab = {
          title: tr("Info"),
          icon: "fa-info-circle",
          content:
          '<div class="row">\
            <div class="large-6 columns">\
              <table id="info_img_table" class="dataTable extended_table">\
                 <thead>\
                  <tr><th colspan="3">'+tr("Information")+'</th></tr>\
                 </thead>\
                 <tr>\
                    <td class="key_td">'+tr("ID")+'</td>\
                    <td class="value_td">'+info.ID+'</td>\
                    <td></td>\
                 </tr>\
                 <tr>\
                  <td class="key_td">'+tr("Name")+'</td>\
                  <td class="value_td_rename">'+info.NAME+'</td>\
                  <td></td>\
                </tr>\
                <tr>\
                <td class="key_td">'+tr("Cluster")+'</td>\
                <td class="value_td_rename">'+info.CLUSTER+'</td>\
                <td></td>\
              </tr>\
              </table>\
           </div>\
           <div class="large-6 columns">' +
           '</div>\
         </div>\
         <div class="row">\
          <div class="large-9 columns">'+
              insert_extended_template_table(info.TEMPLATE,
                                                 "HGroup",
                                                 info.ID,
                                                 "Attributes") +
          '</div>\
        </div>'
      }

    var default_hgroup_quotas = Quotas.default_quotas(info.DEFAULT_HGROUP_QUOTAS);
    var vms_quota = Quotas.vms(info, default_hgroup_quotas);
    var cpu_quota = Quotas.cpu(info, default_hgroup_quotas);
    var memory_quota = Quotas.memory(info, default_hgroup_quotas);
    var volatile_size_quota = Quotas.volatile_size(info, default_hgroup_quotas);
    var image_quota = Quotas.image(info, default_hgroup_quotas);
    var network_quota = Quotas.network(info, default_hgroup_quotas);
    var datastore_quota = Quotas.datastore(info, default_hgroup_quotas);

    var quotas_html;
    if (vms_quota || cpu_quota || memory_quota || volatile_size_quota || image_quota || network_quota || datastore_quota) {
      quotas_html = '<div class="large-6 columns">' + vms_quota + '</div>';
      quotas_html += '<div class="large-6 columns">' + cpu_quota + '</div>';
      quotas_html += '<div class="large-6 columns">' + memory_quota + '</div>';
      quotas_html += '<div class="large-6 columns">' + volatile_size_quota+ '</div>';
      quotas_html += '<br><br>';
      quotas_html += '<div class="large-6 columns">' + image_quota + '</div>';
      quotas_html += '<div class="large-6 columns">' + network_quota + '</div>';
      quotas_html += '<br><br>';
      quotas_html += '<div class="large-12 columns">' + datastore_quota + '</div>';
    } else {
      quotas_html = '<div class="row">\
              <div class="large-12 columns">\
                <p class="subheader">'+tr("No quotas defined")+'</p>\
              </div>\
            </div>'
    }

    var quotas_tab = {
        title : tr("Quotas"),
        icon: "fa-align-left",
        content : quotas_html
    };


    var providers_tab = {
        title : tr("Providers"),
        icon: "fa-th",
        content :
        '<div class="">\
            <div class="large-6 columns">\
                <table id="info_user_table" class="dataTable extended_table">\
                    <thead>\
                        <tr>\
                            <th>' + tr("Zone ID") + '</th>\
                            <th>' + tr("Cluster ID") + '</th>\
                            <th class="text-right">\
                              <button id="add_rp_button" class="button tiny success radius" >\
                                <i class="fa fa-plus-circle"></i>\
                              </button>\
                            </th>\
                        </tr>\
                    </thead>\
                    <tbody>' +
                        fromJSONtoProvidersTable(info) +
                    '</tbody>\
                </table>\
            </div>\
        </div>'
    };

    Sunstone.updateInfoPanelTab("hgroup_info_panel","hgroup_info_tab",info_tab);
    //Sunstone.updateInfoPanelTab("group_info_panel","group_quotas_tab",quotas_tab);
   // Sunstone.updateInfoPanelTab("group_info_panel","group_providers_tab",providers_tab);
    Sunstone.popUpInfoPanel("hgroup_info_panel", 'hgroups-tab');

    $("#add_rp_button", $("#hgroup_info_panel")).click(function(){
        initUpdateHGroupDialog();

        $("a[href=#resource_providers]", $update_hgroup_dialog).click();

        return false;
    });
}

function setup_hgroup_resource_tab_content(zone_id, zone_section, str_zone_tab_id, str_datatable_id, selected_hgroup_clusters, hgroup) {
    // Show the clusters dataTable when the radio button is selected
    $("input[name='"+str_zone_tab_id+"']", zone_section).change(function(){
        if ($("input[name='"+str_zone_tab_id+"']:checked", zone_section).val() == "cluster") {
            $("div.hgroup_cluster_select", zone_section).show();
        }
        else {
            $("div.hgroup_cluster_select", zone_section).hide();
        }
    });

    if (zone_id == 0 && !hgroup)
    {
      $('#'+str_zone_tab_id+'resources_all', zone_section).click();
    }
    else
    {
      $('#'+str_zone_tab_id+'resources_none', zone_section).click();
    }

    var dataTable_hgroup_clusters = $('#'+str_datatable_id, zone_section).dataTable({
        "iDisplayLength": 4,
        "sDom" : '<"H">t<"F"p>',
        "bAutoWidth":false,
        "bSortClasses" : false,
        "bDeferRender": true,
        "aoColumnDefs": [
            { "sWidth": "35px", "aTargets": [0,1] },
            { "bVisible": false, "aTargets": []}
        ]
    });

    // Retrieve the clusters to fill the datatable
    update_datatable_hgroup_clusters(dataTable_hgroup_clusters, zone_id, str_zone_tab_id, hgroup);

    $('#'+str_zone_tab_id+'_search', zone_section).keyup(function(){
        dataTable_hgroup_clusters.fnFilter( $(this).val() );
    })

    dataTable_hgroup_clusters.fnSort( [ [1,config['user_config']['table_order']] ] );

    $('#'+str_datatable_id + '  tbody', zone_section).delegate("tr", "click", function(e){
        var aData   = dataTable_hgroup_clusters.fnGetData(this);

        if (!aData){
            return true;
        }

        var cluster_id = aData[1];

        if ($.isEmptyObject(selected_hgroup_clusters[zone_id])) {
            $('#you_selected_hgroup_clusters'+str_zone_tab_id,  zone_section).show();
            $("#select_hgroup_clusters"+str_zone_tab_id, zone_section).hide();
        }

        if(!$("td:first", this).hasClass('markrowchecked'))
        {
            $('input.check_item', this).attr('checked','checked');
            selected_hgroup_clusters[zone_id][cluster_id] = this;
            $(this).children().each(function(){$(this).addClass('markrowchecked');});
            if ($('#tag_cluster_'+aData[1], $('.selected_hgroup_clusters', zone_section)).length == 0 ) {
                $('.selected_hgroup_clusters', zone_section).append('<span id="tag_cluster_'+aData[1]+'" class="radius label">'+aData[2]+' <span class="fa fa-times blue"></span></span> ');
            }
        }
        else
        {
            $('input.check_item', this).removeAttr('checked');
            delete selected_hgroup_clusters[zone_id][cluster_id];
            $(this).children().each(function(){$(this).removeClass('markrowchecked');});
            $('.selected_hgroup_clusters span#tag_cluster_'+cluster_id, zone_section).remove();
        }

        if ($.isEmptyObject(selected_hgroup_clusters[zone_id])) {
            $('#you_selected_hgroup_clusters'+str_zone_tab_id,  zone_section).hide();
            $('#select_hgroup_clusters'+str_zone_tab_id, zone_section).show();
        }

        $('.alert-box', $('.hgroup_cluster_select')).hide();

        return true;
    });

    $( '#' +str_zone_tab_id+'Tab .fa-times' ).live( "click", function() {
        $(this).parent().remove();
        var id = $(this).parent().attr("ID");

        var cluster_id=id.substring(12,id.length);

        $('td', selected_hgroup_clusters[zone_id][cluster_id]).removeClass('markrowchecked');
        $('input.check_item', selected_hgroup_clusters[zone_id][cluster_id]).removeAttr('checked');
        delete selected_hgroup_clusters[zone_id][cluster_id];

        if ($.isEmptyObject(selected_hgroup_clusters[zone_id])) {
            $('#you_selected_hgroup_clusters'+str_zone_tab_id, zone_section).hide();
            $('#select_hgroup_clusters'+str_zone_tab_id, zone_section).show();
        }
    });

    setupTips(zone_section);
}

function generate_hgroup_resource_tab_content(str_zone_tab_id, str_datatable_id, zone_id, hgroup){
    var html =
    '<div class="row">\
      <div class="large-12 columns">\
          <p class="subheader">' +  tr("Assign physical resources") + '\
            &emsp;<span class="tip">'+tr("For each OpenNebula Zone, you can assign cluster resources (set of physical hosts, datastores and virtual networks) to this hgroup.")+'</span>\
          </p>\
      </div>\
    </div>\
    <div class="row">\
      <div class="large-12 columns">\
          <input type="radio" name="'+str_zone_tab_id+'" id="'+str_zone_tab_id+'resources_all" value="all"><label for="'+str_zone_tab_id+'resources_all">'+tr("All")+'</label>\
          <input type="radio" name="'+str_zone_tab_id+'" id="'+str_zone_tab_id+'resources_cluster" value="cluster"><label for="'+str_zone_tab_id+'resources_cluster">'+tr("Select clusters")+'</label>\
          <input type="radio" name="'+str_zone_tab_id+'" id="'+str_zone_tab_id+'resources_none" value="none"><label for="'+str_zone_tab_id+'resources_none">'+tr("None")+'</label>\
      </div>\
    </div>\
    <div class="row">\
      <div class="large-12 columns">\
        <div id="req_type" class="hgroup_cluster_select hidden">\
            <div class="row collapse ">\
              <div class="large-9 columns">\
               <button id="refresh_hgroup_clusters_table_button_class'+str_zone_tab_id+'" type="button" class="refresh button small radius secondary"><i class="fa fa-refresh" /></button>\
              </div>\
              <div class="large-3 columns">\
                <input id="'+str_zone_tab_id+'_search" class="search" type="text" placeholder="'+tr("Search")+'"/>\
              </div>\
            </div>\
            <table id="'+str_datatable_id+'" class="datatable twelve">\
              <thead>\
              <tr>\
                <th></th>\
                <th>' + tr("ID") + '</th>\
                <th>' + tr("Name") + '</th>\
                <th>' + tr("Hosts") + '</th>\
                <th>' + tr("VNets") + '</th>\
                <th>' + tr("Datastores") + '</th>\
              </tr>\
              </thead>\
              <tbody id="tbodyclusters">\
              </tbody>\
            </table>\
            <br>\
            <div class="selected_hgroup_clusters">\
              <span id="select_hgroup_clusters'+str_zone_tab_id+'" class="radius secondary label">'+tr("Please select one or more clusters from the list")+'</span> \
              <span id="you_selected_hgroup_clusters'+str_zone_tab_id+'" class="radius secondary label hidden">'+tr("You selected the following clusters:")+'</span> \
            </div>\
            <br>\
        </div\
      </div>\
    </div>';

    $("#refresh_hgroup_clusters_table_button_class"+str_zone_tab_id).die();
    $("#refresh_hgroup_clusters_table_button_class"+str_zone_tab_id).live('click', function(){
        update_datatable_hgroup_clusters(
            $('table[id='+str_datatable_id+']').dataTable(),
            zone_id, str_zone_tab_id, hgroup);
    });

    return html;
}

// TODO: Refactor? same function in templates-tab.js
function update_datatable_hgroup_clusters(datatable, zone_id, str_zone_tab_id, hgroup) {

    OpenNebula.Cluster.list_in_zone({
        data:{zone_id:zone_id},
        timeout: true,
        success: function (request, obj_list){
            var obj_list_array = [];

            $.each(obj_list,function(){
                //Grab table data from the obj_list
                obj_list_array.push(clusterElementArray(this));
            });

            updateView(obj_list_array, datatable);

            if (hgroup && hgroup.RESOURCE_PROVIDER)
            {
                var rows = datatable.fnGetNodes();
                providers_array = hgroup.RESOURCE_PROVIDER;

                if (!$.isArray(providers_array))
                {
                    providers_array = [providers_array];
                }

                $('#'+str_zone_tab_id+'resources_none').click();

                $.each(providers_array, function(index, provider){
                    if (provider.ZONE_ID==zone_id)
                    {
                        for(var j=0;j<rows.length;j++)
                        {
                            var current_row    = $(rows[j]);
                            var row_cluster_id = $(rows[j]).find("td:eq(1)").html();

                            if (provider.CLUSTER_ID == row_cluster_id)
                            {
                                current_row.click();
                            }
                        }
                        if (provider.CLUSTER_ID == "10")
                            $('#'+str_zone_tab_id+'resources_all').click();
                        else
                            $('#'+str_zone_tab_id+'resources_cluster').click();
                    }
                });
            }
        }
    });
};

var add_resource_tab = function(zone_id, zone_name, dialog, selected_hgroup_clusters, hgroup) {
    var str_zone_tab_id  = dialog.attr('id') + '_zone' + zone_id;
    var str_datatable_id = dialog.attr('id') + '_datatable_hgroup_clusters_zone_' + zone_id;

    selected_hgroup_clusters[zone_id] = {};

    // Append the new div containing the tab and add the tab to the list
    var html_tab_content = '<div id="'+str_zone_tab_id+'Tab" class="content">'+
        generate_hgroup_resource_tab_content(str_zone_tab_id, str_datatable_id, zone_id, hgroup) +
        '</div>'
    $(html_tab_content).appendTo($(".hgroup_zones_tabs_content", dialog));

    var a = $("<dd>\
        <a id='zone_tab"+str_zone_tab_id+"' href='#"+str_zone_tab_id+"Tab'>"+zone_name+"</a>\
        </dd>").appendTo($("dl#hgroup_zones_tabs", dialog));

    // TODOO
    //$(document).foundationTabs("set_tab", a);
    $("dl#hgroup_zones_tabs", dialog).children("dd").first().children("a").click();

    var zone_section = $('#' +str_zone_tab_id+'Tab', dialog);
    setup_hgroup_resource_tab_content(zone_id, zone_section, str_zone_tab_id, str_datatable_id, selected_hgroup_clusters, hgroup);
};

function disableAdminUser(dialog){
    $('#username',dialog).attr('disabled','disabled');
    $('#pass',dialog).attr('disabled','disabled');
    $('#driver',dialog).attr('disabled','disabled');
    $('#custom_auth',dialog).attr('disabled','disabled');
};

function enableAdminUser(dialog){
    $('#username',dialog).removeAttr("disabled");
    $('#pass',dialog).removeAttr("disabled");
    $('#driver',dialog).removeAttr("disabled");
    $('#custom_auth',dialog).removeAttr("disabled");
};

//Prepares the dialog to create
function setupCreateHGroupDialog(){
    dialogs_context.append('<div id="create_hgroup_dialog"></div>');
    $create_hgroup_dialog = $('#create_hgroup_dialog',dialogs_context);
    var dialog = $create_hgroup_dialog;

    dialog.html(create_hgroup_tmpl('create'));
    dialog.addClass("reveal-modal large max-height").attr("data-reveal", "");
    $(document).foundation();

    // Hide update buttons
    $('#update_hgroup_submit',$create_hgroup_dialog).hide();
    $('#update_hgroup_header',$create_hgroup_dialog).hide();

    setupTips($create_hgroup_dialog);

    $('#create_hgroup_reset_button').click(function(){
        $create_hgroup_dialog.html("");
        setupCreateHGroupDialog();

        popUpCreateHGroupDialog();
    });

    setupCustomAuthDialog(dialog);

    $('input#name', dialog).change(function(){
        var val = $(this).val();
        var dialog = $create_hgroup_dialog;

        $('#username',dialog).val(val + "-admin");
    });

    $('input#admin_user', dialog).change(function(){
        var dialog = $create_hgroup_dialog;
        if ($(this).prop('checked')) {
            enableAdminUser(dialog);

            $.each($('[id^="hgroup_admin_res"]', dialog), function(){
                $(this).removeAttr("disabled");
            });
        } else {
            disableAdminUser(dialog);

            $.each($('[id^="hgroup_admin_res"]', dialog), function(){
                $(this).attr('disabled', 'disabled');
            });
        }
    });

    disableAdminUser(dialog);

    $.each($('[id^="hgroup_res"]', dialog), function(){
        $(this).prop("checked", true);
    });

    $.each($('[id^="hgroup_admin_res"]', dialog), function(){
        $(this).attr('disabled', 'disabled');
        $(this).prop("checked", true);
    });

    $("#hgroup_res_net", dialog).prop("checked", false);
    $("#hgroup_admin_res_net", dialog).prop("checked", false);

    var selected_hgroup_clusters = {};

    OpenNebula.Zone.list({
        timeout: true,
        success: function (request, obj_list){
            $.each(obj_list,function(){
                add_resource_tab(this.ZONE.ID,
                    this.ZONE.NAME,
                    dialog,
                    selected_hgroup_clusters);
            });
        },
        error: onError
    });

    $('#create_hgroup_form',dialog).submit(function(){
        var name = $('#name',this).val();

        var user_json = null;

        if ( $('#admin_user', this).prop('checked') ){
            user_json = buildUserJSON(this);    // from users-tab.js

            if (!user_json) {
                notifyError(tr("User name and password must be filled in"));
                return false;
            }
        }

        var hgroup_json = {
            "hgroup" : {
                "name" : name
            }
        };

        if (user_json){
            hgroup_json["hgroup"]["hgroup_admin"] = user_json["user"];
        }

        hgroup_json['hgroup']['resource_providers'] = [];

        $.each(selected_hgroup_clusters, function(zone_id, zone_clusters) {
            var str_zone_tab_id = dialog.attr('id') + '_zone' + zone_id;

            var resource_selection = $("input[name='"+str_zone_tab_id+"']:checked", dialog).val();
            switch (resource_selection){
            case "all":
                // 10 is the special ID for ALL, see ClusterPool.h
                hgroup_json['hgroup']['resource_providers'].push(
                    {"zone_id" : zone_id, "cluster_id" : 10}
                );

                break;
            case "cluster":
                $.each(selected_hgroup_clusters[zone_id], function(key, value) {
                    hgroup_json['hgroup']['resource_providers'].push(
                        {"zone_id" : zone_id, "cluster_id" : key}
                    );
                });

                break;
            default: // "none"

            }
        });

        var resources = "";
        var separator = "";

        $.each($('[id^="hgroup_res"]:checked', dialog), function(){
            resources += (separator + $(this).val());
            separator = "+";
        });

        hgroup_json['hgroup']['resources'] = resources;

        if (user_json){
            resources = "";
            separator = "";

            $.each($('[id^="hgroup_admin_res"]:checked', dialog), function(){
                resources += (separator + $(this).val());
                separator = "+";
            });

            hgroup_json["hgroup"]["hgroup_admin"]["resources"] = resources;
        }

        hgroup_json['hgroup']['views'] = [];

        $.each($('[id^="hgroup_view"]:checked', dialog), function(){
            hgroup_json['hgroup']['views'].push($(this).val());
        });


        Sunstone.runAction("HGroup.create",hgroup_json);
        return false;
    });
}

function popUpCreateHGroupDialog(){
    $create_hgroup_dialog.foundation().foundation('reveal', 'open');
    $("input#name",$create_hgroup_dialog).focus();
}

//Prepares the dialog to update
function setupUpdateHGroupDialog(){
    if (typeof($update_hgroup_dialog) !== "undefined"){
        $update_hgroup_dialog.html("");
    }

    dialogs_context.append('<div id="update_hgroup_dialog"></div>');
    $update_hgroup_dialog = $('#update_hgroup_dialog',dialogs_context);
    var dialog = $update_hgroup_dialog;

    dialog.html(create_hgroup_tmpl('update'));
    dialog.addClass("reveal-modal large max-height").attr("data-reveal", "");
    $(document).foundation();

    setupTips($update_hgroup_dialog);

    // Hide create button
    $('#create_hgroup_submit',$update_hgroup_dialog).hide();
    $('#create_hgroup_header',$update_hgroup_dialog).hide();
    $('#create_hgroup_reset_button',$update_hgroup_dialog).hide();

    // Disable parts of the wizard
    $("input#name", dialog).attr("disabled", "disabled");

    $("a[href='#administrators']", dialog).parents("dd").hide();
    $("a[href='#resource_creation']", dialog).parents("dd").hide();

    $update_hgroup_dialog.foundation();
}

function initUpdateHGroupDialog(){
    var selected_nodes = getSelectedNodes(dataTable_hgroups);

    if ( selected_nodes.length != 1 )
    {
        notifyMessage("Please select one (and just one) hgroup to update.");
        return false;
    }

    // Get proper id
    var hgroup_id = ""+selected_nodes[0];

    setupUpdateHGroupDialog();

    Sunstone.runAction("HGroup.show_to_update", hgroup_id);
}

function popUpUpdateHGroupDialog(hgroup, dialog)
{
    var dialog = $update_hgroup_dialog;

    dialog.foundation('reveal', 'open');

    $("input#name",$update_hgroup_dialog).val(hgroup.NAME);

    var views_str = "";

    if (hgroup.TEMPLATE.SUNSTONE_VIEWS){
        views_str = hgroup.TEMPLATE.SUNSTONE_VIEWS;

        var views = views_str.split(",");
        $.each(views, function(){
            $('input[id^="hgroup_view"][value="'+this.trim()+'"]', dialog).attr('checked','checked');
        });
    }

    var selected_hgroup_clusters = {};

    OpenNebula.Zone.list({
        timeout: true,
        success: function (request, obj_list){
            $.each(obj_list,function(){
                add_resource_tab(this.ZONE.ID,
                                 this.ZONE.NAME,
                                 dialog,
                                 selected_hgroup_clusters,
                                 hgroup);
            });
        },
        error: onError
    });


    $(dialog).off("click", 'button#update_hgroup_submit');
    $(dialog).on("click", 'button#update_hgroup_submit', function(){

        // Update Views
        //-------------------------------------
        var new_views_str = "";
        var separator     = "";

        $.each($('[id^="hgroup_view"]:checked', dialog), function(){
            new_views_str += (separator + $(this).val());
            separator = ",";
        });

        if (new_views_str != views_str){
            var template_json = hgroup.TEMPLATE;
            delete template_json["SUNSTONE_VIEWS"];
            template_json["SUNSTONE_VIEWS"] = new_views_str;

            var template_str = convert_template_to_string(template_json);

            Sunstone.runAction("HGroup.update_template",hgroup.ID,template_str);
        }

        // Update Resource Providers
        //-------------------------------------

        var old_resource_providers = hgroup.RESOURCE_PROVIDER;

        if (!old_resource_providers) {
            old_resource_providers = new Array();
        } else if (!$.isArray(old_resource_providers)) {
            old_resource_providers = [old_resource_providers];
        }

        var new_resource_providers = [];

        $.each(selected_hgroup_clusters, function(zone_id, zone_clusters) {
            var str_zone_tab_id = dialog.attr('id') + '_zone' + zone_id;

            var resource_selection = $("input[name='"+str_zone_tab_id+"']:checked", dialog).val();
            switch (resource_selection){
            case "all":
                // 10 is the special ID for ALL, see ClusterPool.h
                new_resource_providers.push(
                    {"zone_id" : zone_id, "cluster_id" : 10}
                );

                break;
            case "cluster":
                $.each(selected_hgroup_clusters[zone_id], function(key, value) {
                    new_resource_providers.push(
                        {"zone_id" : zone_id, "cluster_id" : key}
                    );
                });

                break;
            default: // "none"

            }
        });

        $.each(old_resource_providers, function(index, old_res_provider){
            found = false;

            $.each(new_resource_providers, function(index, new_res_provider){
                found = (old_res_provider.ZONE_ID == new_res_provider.zone_id &&
                         old_res_provider.CLUSTER_ID == new_res_provider.cluster_id);

                return !found;
            });

            if (!found) {
                var extra_param = {
                    "zone_id"    : old_res_provider.ZONE_ID,
                    "cluster_id" : old_res_provider.CLUSTER_ID
                };

                Sunstone.runAction("HGroup.del_provider_action",
                                   hgroup.ID,
                                   extra_param);
            }
        });

        $.each(new_resource_providers, function(index, new_res_provider){
            found = false;

            $.each(old_resource_providers, function(index, old_res_provider){
                found = (old_res_provider.ZONE_ID == new_res_provider.zone_id &&
                         old_res_provider.CLUSTER_ID == new_res_provider.cluster_id);

                return !found;
            });

            if (!found) {
                var extra_param = new_res_provider;

                Sunstone.runAction("HGroup.add_provider_action",
                                   hgroup.ID,
                                   extra_param);
            }
        });

        // Close the dialog
        //-------------------------------------

        dialog.foundation('reveal', 'close');

        return false;
    });

}

// Add groups quotas dialog and calls common setup() in sunstone utils.
function setupHGroupQuotasDialog(){
    dialogs_context.append('<div title="'+tr("HGroup quotas")+'" id="hgroup_quotas_dialog"></div>');
    $hgroup_quotas_dialog = $('#hgroup_quotas_dialog',dialogs_context);
    var dialog = $hgroup_quotas_dialog;
    dialog.html(hgroup_quotas_tmpl);

    setupQuotasDialog(dialog);
}

function popUpHGroupQuotasDialog(){
    popUpQuotasDialog($hgroup_quotas_dialog, 'HGroup', hgroupElements())
}

$(document).ready(function(){
    var tab_name = 'hgroups-tab';

    if (Config.isTabEnabled(tab_name)) {
      dataTable_hgroups = $("#datatable_hgroups",main_tabs_context).dataTable({
            "bSortClasses" : false,
            "bDeferRender": true,
            "aoColumnDefs": [
              { "bSortable": false, "aTargets": ["check",4,5,6] },
              { "sWidth": "35px", "aTargets": [0] },
              { "bVisible": true, "aTargets": Config.tabTableColumns(tab_name)},
              { "bVisible": false, "aTargets": ['_all']}
          ]
      });

      $('#hgroup_search').keyup(function(){
        dataTable_hgroups.fnFilter( $(this).val() );
      })

      dataTable_hgroups.on('draw', function(){
        recountCheckboxes(dataTable_hgroups);
      })

      Sunstone.runAction("HGroup.list");
      setupCreateHGroupDialog();
      setupHGroupQuotasDialog();

      initCheckAllBoxes(dataTable_hgroups);
      tableCheckboxesListener(dataTable_hgroups);
      infoListener(dataTable_hgroups, 'HGroup.show');

      $('div#hgroups_tab div.legend_div').hide();
      $('div#hgroups_tab_non_admin div.legend_div').hide();

      dataTable_hgroups.fnSort( [ [1,config['user_config']['table_order']] ] );
    }
})
