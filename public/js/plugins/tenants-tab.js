/* -------------------------------------------------------------------------- */
/* Copyright 2002-2014, OpenNebula Project (OpenNebula.org), C12G Labs        */
/*                                                                            */
/* Licensed under the Apache License, Version 2.0 (the "License"); you may    */
/* not use this file except in compliance with the License. You may obtain    */
/* a copy of the License at                                                   */
/*                                                                            */
/* http://www.apache.org/licenses/LICENSE-2.0                                 */
/*                                                                            */
/* Unless required by applicable law or agreed to in writing, software        */
/* distributed under the License is distributed on an "AS IS" BASIS,          */
/* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   */
/* See the License for the specific language governing permissions and        */
/* limitations under the License.                                             */
/* -------------------------------------------------------------------------- */

var dataTable_tenants;
var $create_tenant_dialog;
var $tenant_quotas_dialog;

var tenant_acct_graphs = [
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

function create_tenant_tmpl(dialog_name){
    return '<div class="row">\
  <div class="large-12 columns">\
    <h3 id="create_tenant_header">'+tr("Create Tenant")+'</h3>\
    <h3 id="update_tenant_header">'+tr("Update Tenant")+'</h3>\
  </div>\
</div>\
<div class="reveal-body">\
  <form id="create_tenant_form" action="">\
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
            +tr("Allow users in this tenant to use the following Sunstone views")+
            '&emsp;<span class="tip">'+tr("Views available to the tenant users. The default is set in sunstone-views.yaml")+'</span>\
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
            <dl class="tabs" id="tenant_zones_tabs" data-tab></dl>\
            <div class="tabs-content tenant_zones_tabs_content"></div>\
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
                <span class="tip">'+tr("You can create now an administrator user that will be assigned to the new regular tenant, with the administrator tenant as a secondary one.")+'</span>\
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
              +tr("Allow users in this tenant to create the following resources")+
              '&emsp;<span class="tip">'+tr("This will create new ACL Rules to define which virtual resources this tenant's users will be able to create. You can set different resources for the administrator tenant, and decide if the administrators will be allowed to create new users.")+'</span>\
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
                <th>'+tr("Documents")+'<span class="tip">'+tr("Documents are a special tool used for general purposes, mainly by OneFlow. If you want to enable users of this tenant to use service composition via OneFlow, let it checked.")+'</span></th>\
              </tr></thead>\
              <tbody>\
                <tr>\
                  <th>'+tr("Users")+'</th>\
                  <td><input type="checkbox" id="tenant_res_vm" name="tenant_res_vm" class="resource_cb" value="VM"></input></td>\
                  <td><input type="checkbox" id="tenant_res_net" name="tenant_res_net" class="resource_cb" value="NET"></input></td>\
                  <td><input type="checkbox" id="tenant_res_image" name="tenant_res_image" class="resource_cb" value="IMAGE"></input></td>\
                  <td><input type="checkbox" id="tenant_res_template" name="tenant_res_template" class="resource_cb" value="TEMPLATE"></input></td>\
                  <td><input type="checkbox" id="tenant_res_document" name="tenant_res_document" class="resource_cb" value="DOCUMENT"></input></td>\
                  <td/>\
                </tr>\
                <tr>\
                  <th>'+tr("Admins")+'</th>\
                  <td><input type="checkbox" id="tenant_admin_res_vm" name="tenant_admin_res_vm" class="resource_cb" value="VM"></input></td>\
                  <td><input type="checkbox" id="tenant_admin_res_net" name="tenant_admin_res_net" class="resource_cb" value="NET"></input></td>\
                  <td><input type="checkbox" id="tenant_admin_res_image" name="tenant_admin_res_image" class="resource_cb" value="IMAGE"></input></td>\
                  <td><input type="checkbox" id="tenant_admin_res_template" name="tenant_admin_res_template" class="resource_cb" value="TEMPLATE"></input></td>\
                  <td><input type="checkbox" id="tenant_admin_res_document" name="tenant_admin_res_document" class="resource_cb" value="DOCUMENT"></input></td>\
                </tr>\
              </tbody>\
            </table>\
        </div>\
      </div>\
    </div>\
  </div>\
  <div class="reveal-footer">\
    <div class="form_buttons">\
      <button class="button radius right success" id="create_tenant_submit" value="Tenant.create">'+tr("Create")+'</button>\
       <button class="button right radius" type="submit" id="update_tenant_submit">' + tr("Update") + '</button>\
      <button class="button secondary radius" id="create_tenant_reset_button" type="reset" value="reset">'+tr("Reset")+'</button>\
    </div>\
  </div>\
  <a class="close-reveal-modal">&#215;</a>\
  </form>\
</div>';
}

var tenant_quotas_tmpl = '<div class="row" class="subheader">\
  <div class="large-12 columns">\
    <h3 id="create_tenant_quotas_header">'+tr("Update Quota")+'</h3>\
  </div>\
</div>\
<div class="reveal-body">\
<form id="tenant_quotas_form" action="">quotas_tmpl<div class="reveal-footer">\
    <div class="form_buttons">\
        <button class="button radius right success" id="create_user_submit" type="submit" value="Tenant.set_quota">'+tr("Apply changes")+'</button>\
    </div>\
  </div>\
  <a class="close-reveal-modal">&#215;</a>\
</form>\
</div>';


var tenant_actions = {
    "Tenant.create" : {
        type: "create",
        call : OpenNebula.Tenant.create,
        callback : function(request, response) {
            // Reset the create wizard
            $create_tenant_dialog.foundation('reveal', 'close');
            $create_tenant_dialog.empty();
            setupCreateTenantDialog();

            OpenNebula.Helper.clear_cache("USER");

            Sunstone.runAction("Gtenantlist");
            notifyCustom(tr("Tenant created"), " ID: " + response.TENANT.ID, false);
        },
        error : onError
    },

    "Tenant.create_dialog" : {
        type: "custom",
        call: popUpCreateTenantDialog
    },

    "Tenant.list" : {
        type: "list",
        call: OpenNebula.Tenant.list,
        callback: updateTenantsView,
        error: onError
    },

    "Tenant.show" : {
        type: "single",
        call: OpenNebula.Tenant.show,
        callback:   function(request, response) {
            updateTenantElement(request, response);
            if (Sunstone.rightInfoVisible($("#tenants-tab"))) {
                updateTenantInfo(request, response);
            }
        },
        error: onError
    },

    "Tenant.refresh" : {
        type: "custom",
        call: function() {
          var tab = dataTable_tenants.parents(".tab");
          if (Sunstone.rightInfoVisible(tab)) {
            Sunstone.runAction("Tenant.show", Sunstone.rightInfoResourceId(tab))
          } else {
            waitingNodes(dataTable_tenants);
            Sunstone.runAction("Tenant.list", {force: true});
          }
        },
        error: onError
    },

    "Tenant.update_template" : {
        type: "single",
        call: OpenNebula.Tenant.update,
        callback: function(request) {
            Sunstone.runAction('Tenant.show',request.request.data[0][0]);
        },
        error: onError
    },

    "Tenant.update_dialog" : {
        type: "single",
        call: initUpdateTenantDialog
    },

    "Tenant.show_to_update" : {
        type: "single",
        call: OpenNebula.Tenant.show,
        callback: function(request, response) {
            popUpUpdateTenantDialog(
                response.TENANT,
                $create_tenant_dialog);
        },
        error: onError
    },

    "Tenant.delete" : {
        type: "multiple",
        call : OpenNebula.Tenant.del,
        callback : deleteTenantElement,
        error : onError,
        elements: tenantElements
    },

    "Tenant.fetch_quotas" : {
        type: "single",
        call: OpenNebula.Tenant.show,
        callback: function (request,response) {
            var parsed = parseQuotas(response.TENANT,quotaListItem);
            $('.current_quotas table tbody',$tenant_quotas_dialog).append(parsed.VM);
            $('.current_quotas table tbody',$tenant_quotas_dialog).append(parsed.DATASTORE);
            $('.current_quotas table tbody',$tenant_quotas_dialog).append(parsed.IMAGE);
            $('.current_quotas table tbody',$tenant_quotas_dialog).append(parsed.NETWORK);
        },
        error: onError
    },

    "Tenant.quotas_dialog" : {
        type: "custom",
        call: popUpTenantQuotasDialog
    },

    "Tenant.set_quota" : {
        type: "multiple",
        call: OpenNebula.Tenant.set_quota,
        elements: tenantElements,
        callback: function(request,response) {
            Sunstone.runAction('Tenant.show',request.request.data[0]);
        },
        error: onError
    },

    "Tenant.accounting" : {
        type: "monitor",
        call: OpenNebula.Tenant.accounting,
        callback: function(req,response) {
            var info = req.request.data[0].monitor;
            //plot_graph(response,'#Tenant_acct_tabTab','Tenant_acct_', info);
        },
        error: onError
    },


    "Tenant.add_provider_action" : {
        type: "single",
        call: OpenNebula.Tenant.add_provider,
        callback: function(request) {
           Sunstone.runAction('Tenant.show',request.request.data[0][0]);
        },
        error: onError
    },

    "Tenant.del_provider_action" : {
        type: "single",
        call: OpenNebula.Tenant.del_provider,
        callback: function(request) {
          Sunstone.runAction('Tenant.show',request.request.data[0][0]);
        },
        error: onError
    },

    "Tenant.add_provider" : {
        type: "multiple",
        call: function(params){
            var cluster = params.data.extra_param;
            var tenant   = params.data.id;

            extra_param = {
                "zone_id" : 0,
                "cluster_id" : cluster
            }

            Sunstone.runAction("Tenant.add_provider_action", tenant, extra_param);
        },
        callback: function(request) {
            Sunstone.runAction('Tenant.show',request.request.data[0]);
        },
        elements: tenantElements
    },

    "Tenant.del_provider" : {
        type: "multiple",
        call: function(params){
            var cluster = params.data.extra_param;
            var tenant   = params.data.id;

            extra_param = {
                "zone_id" : 0,
                "cluster_id" : cluster
            }

            Sunstone.runAction("Tenant.del_provider_action", tenant, extra_param);
        },
        callback: function(request) {
            Sunstone.runAction('Tenant.show',request.request.data[0]);
        },
        elements: tenantElements
    }
}

var tenant_buttons = {
    "Tenant.refresh" : {
        type: "action",
        layout: "refresh",
        alwaysActive: true
    },
//    "Sunstone.toggle_top" : {
//        type: "custom",
//        layout: "top",
//        alwaysActive: true
//    },
    "Tenant.create_dialog" : {
        type: "create_dialog",
        layout: "create",
        condition: mustBeAdmin
    },
    "Tenant.update_dialog" : {
        type : "action",
        layout: "main",
        text : tr("Update")
    },
    "Tenant.quotas_dialog" : {
        type : "action",
        text : tr("Quotas"),
        layout: "main",
        condition: mustBeAdmin
    },
    "Tenant.delete" : {
        type: "confirm",
        text: tr("Delete"),
        layout: "del",
        condition: mustBeAdmin
    },
};

var tenant_info_panel = {

};

var tenants_tab = {
    title: tr("Tenants"),
    resource: 'Tenant',
    buttons: tenant_buttons,
    tabClass: 'subTab',
    parentTab: 'system-tab',
    search_input: '<input id="tenant_search" type="text" placeholder="'+tr("Search")+'" />',
    list_header: '<i class="fa fa-fw fa-users"></i>&emsp;'+tr("Tenants"),
    info_header: '<i class="fa fa-fw fa-users"></i>&emsp;'+tr("Tenant"),
    subheader: '<span>\
        <span class="total_tenants"/> <small>'+tr("TOTAL")+'</small>\
      </span>',
    table: '<table id="datatable_tenants" class="datatable twelve">\
      <thead>\
        <tr>\
          <th class="check"><input type="checkbox" class="check_all" value=""></input></th>\
          <th>'+tr("ID")+'</th>\
          <th>'+tr("Name")+'</th>\
          <th>'+tr("Hosts")+'</th>\
          <th>'+tr("Cluster")+'</th>\
          <th>'+tr("Memory")+'</th>\
          <th>'+tr("CPU")+'</th>\
        </tr>\
      </thead>\
      <tbody id="tbodytenants">\
      </tbody>\
    </table>'
};


Sunstone.addActions(tenant_actions);
Sunstone.addMainTab('tenants-tab',tenants_tab);
Sunstone.addInfoPanel("tenant_info_panel",tenant_info_panel);

function insert_views(dialog_name){
  views_checks_str = ""
  var views_array = config['available_views'];
  for (var i = 0; i < views_array.length; i++)
  {
    var checked = views_array[i] == 'cloud' ? "checked" : "";

    views_checks_str = views_checks_str +
             '<input type="checkbox" id="tenant_view_'+dialog_name+'_'+views_array[i]+
                '" value="'+views_array[i]+'" '+checked+'/>' +
             '<label for="tenant_view_'+dialog_name+'_'+views_array[i]+'">'+views_array[i]+
             '</label>'
  }
  return views_checks_str;
}

function tenantElements(){
    return getSelectedNodes(dataTable_tenants);
}

function tenantElementArray(tenant_json){
    var tenant = tenant_json.TENANT;

    var users_str = "0";

    if (tenant.USERS.ID){
        if ($.isArray(tenant.USERS.ID)){
            users_str = tenant.USERS.ID.length;
        } else {
            users_str = "1";
        }
    }

    var vms = "-";
    var memory = "-";
    var cpu = "-";

    if (!$.isEmptyObject(tenant.VM_QUOTA)){

        var vms = quotaBar(
            tenant.VM_QUOTA.VM.VMS_USED,
            tenant.VM_QUOTA.VM.VMS,
            default_tenant_quotas.VM_QUOTA.VM.VMS);

        var memory = quotaBarMB(
            tenant.VM_QUOTA.VM.MEMORY_USED,
            tenant.VM_QUOTA.VM.MEMORY,
            default_tenant_quotas.VM_QUOTA.VM.MEMORY);

        var cpu = quotaBarFloat(
            tenant.VM_QUOTA.VM.CPU_USED,
            tenant.VM_QUOTA.VM.CPU,
            default_tenant_quotas.VM_QUOTA.VM.CPU);
    }

    return [
        '<input class="check_item" type="checkbox" id="tenant_'+tenant.ID+'" name="selected_items" value="'+tenant.NAME+'"/>',
        tenant.ID,
        tenant.NAME,
        tenant.NOOFHOSTS,
        tenant.CLUSTER,
        memory,
        cpu
    ];
}

function updateTenantElement(request, tenant_json){
    var id = tenant_json.TENANT.ID;
    var element = tenantElementArray(tenant_json);
    updateSingleElement(element,dataTable_tenants,'#tenant_'+id);
    //No need to update select as all items are in it always
}

function deleteTenantElement(request){
    deleteElement(dataTable_tenants,'#tenant_'+request.request.data);
}

function addTenantElement(request,tenant_json){
    var id = tenant_json.TENANT.ID;
    var element = tenantElementArray(tenant_json);
    addElement(element,dataTable_tenants);
}

//updates the list
function updateTenantsView(request, tenant_list, quotas_hash){
    tenant_list_json = tenant_list;
    var tenant_list_array = [];

    $.each(tenant_list,function(){
        // Inject the VM tenant quota. This info is returned separately in the
        // pool info call, but the tenantElementArray expects it inside the tenant,
        // as it is returned by the individual info call
        var q = quotas_hash[this.TENANT.ID];

        if (q != undefined) {
            this.TENANT.VM_QUOTA = q.QUOTAS.VM_QUOTA;
        }

        tenant_list_array.push(tenantElementArray(this));
    });
    updateView(tenant_list_array,dataTable_tenants);

    // Dashboard info
    $(".total_tenants").text(tenant_list.length);
}

function fromJSONtoProvidersTable(tenant_info){
    providers_array=tenant_info.RESOURCE_PROVIDER
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
               <a id="div_minus_rp_a_'+provider.ZONE_ID+'" class="cluster_id_'+cluster_id+' tenant_id_'+tenant_info.ID+'" href="#"><i class="fa fa-trash-o"/></a>\
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
              if (value.match(/^tenant_id_/))
              {
                tenant_id=value.substring(9,value.length);
              }
            }

        });

        extra_param = {
            "zone_id" : zone_id,
            "cluster_id" :  (cluster_id == "All") ? 10 : cluster_id
        }

        Sunstone.runAction("Tenant.del_provider_action", tenant_id, extra_param);
    });

    return str;
}

function updateTenantInfo(request,tenant){
    var info = tenant.TENANT;

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
                                                 "tenant",
                                                 info.ID,
                                                 "Attributes") +
          '</div>\
        </div>'
      }

    var default_tenant_quotas = Quotas.default_quotas(info.DEFAULT_TENANT_QUOTAS);
    var vms_quota = Quotas.vms(info, default_tenant_quotas);
    var cpu_quota = Quotas.cpu(info, default_tenant_quotas);
    var memory_quota = Quotas.memory(info, default_tenant_quotas);
    var volatile_size_quota = Quotas.volatile_size(info, default_tenant_quotas);
    var image_quota = Quotas.image(info, default_tenant_quotas);
    var network_quota = Quotas.network(info, default_tenant_quotas);
    var datastore_quota = Quotas.datastore(info, default_tenant_quotas);

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

    Sunstone.updateInfoPanelTab("tenant_info_panel","tenant_info_tab",info_tab);
    //Sunstone.updateInfoPanelTab("tenant_info_panel","tenant_quotas_tab",quotas_tab);
   // Sunstone.updateInfoPanelTab("tenant_info_panel","tenant_providers_tab",providers_tab);
    Sunstone.popUpInfoPanel("tenant_info_panel", 'tenants-tab');

    $("#add_rp_button", $("#tenant_info_panel")).click(function(){
        initUpdateTenantDialog();

        $("a[href=#resource_providers]", $update_tenant_dialog).click();

        return false;
    });
}

function setup_tenant_resource_tab_content(zone_id, zone_section, str_zone_tab_id, str_datatable_id, selected_tenant_clusters, tenant) {
    // Show the clusters dataTable when the radio button is selected
    $("input[name='"+str_zone_tab_id+"']", zone_section).change(function(){
        if ($("input[name='"+str_zone_tab_id+"']:checked", zone_section).val() == "cluster") {
            $("div.tenant_cluster_select", zone_section).show();
        }
        else {
            $("div.tenant_cluster_select", zone_section).hide();
        }
    });

    if (zone_id == 0 && !tenant)
    {
      $('#'+str_zone_tab_id+'resources_all', zone_section).click();
    }
    else
    {
      $('#'+str_zone_tab_id+'resources_none', zone_section).click();
    }

    var dataTable_tenant_clusters = $('#'+str_datatable_id, zone_section).dataTable({
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
    update_datatable_tenant_clusters(dataTable_tenant_clusters, zone_id, str_zone_tab_id, tenant);

    $('#'+str_zone_tab_id+'_search', zone_section).keyup(function(){
        dataTable_tenant_clusters.fnFilter( $(this).val() );
    })

    dataTable_tenant_clusters.fnSort( [ [1,config['user_config']['table_order']] ] );

    $('#'+str_datatable_id + '  tbody', zone_section).delegate("tr", "click", function(e){
        var aData   = dataTable_tenant_clusters.fnGetData(this);

        if (!aData){
            return true;
        }

        var cluster_id = aData[1];

        if ($.isEmptyObject(selected_tenant_clusters[zone_id])) {
            $('#you_selected_tenant_clusters'+str_zone_tab_id,  zone_section).show();
            $("#select_tenant_clusters"+str_zone_tab_id, zone_section).hide();
        }

        if(!$("td:first", this).hasClass('markrowchecked'))
        {
            $('input.check_item', this).attr('checked','checked');
            selected_tenant_clusters[zone_id][cluster_id] = this;
            $(this).children().each(function(){$(this).addClass('markrowchecked');});
            if ($('#tag_cluster_'+aData[1], $('.selected_tenant_clusters', zone_section)).length == 0 ) {
                $('.selected_tenant_clusters', zone_section).append('<span id="tag_cluster_'+aData[1]+'" class="radius label">'+aData[2]+' <span class="fa fa-times blue"></span></span> ');
            }
        }
        else
        {
            $('input.check_item', this).removeAttr('checked');
            delete selected_tenant_clusters[zone_id][cluster_id];
            $(this).children().each(function(){$(this).removeClass('markrowchecked');});
            $('.selected_tenant_clusters span#tag_cluster_'+cluster_id, zone_section).remove();
        }

        if ($.isEmptyObject(selected_tenant_clusters[zone_id])) {
            $('#you_selected_tenant_clusters'+str_zone_tab_id,  zone_section).hide();
            $('#select_tenant_clusters'+str_zone_tab_id, zone_section).show();
        }

        $('.alert-box', $('.tenant_cluster_select')).hide();

        return true;
    });

    $( '#' +str_zone_tab_id+'Tab .fa-times' ).live( "click", function() {
        $(this).parent().remove();
        var id = $(this).parent().attr("ID");

        var cluster_id=id.substring(12,id.length);

        $('td', selected_tenant_clusters[zone_id][cluster_id]).removeClass('markrowchecked');
        $('input.check_item', selected_tenant_clusters[zone_id][cluster_id]).removeAttr('checked');
        delete selected_tenant_clusters[zone_id][cluster_id];

        if ($.isEmptyObject(selected_tenant_clusters[zone_id])) {
            $('#you_selected_tenant_clusters'+str_zone_tab_id, zone_section).hide();
            $('#select_tenant_clusters'+str_zone_tab_id, zone_section).show();
        }
    });

    setupTips(zone_section);
}

function generate_tenant_resource_tab_content(str_zone_tab_id, str_datatable_id, zone_id, tenant){
    var html =
    '<div class="row">\
      <div class="large-12 columns">\
          <p class="subheader">' +  tr("Assign physical resources") + '\
            &emsp;<span class="tip">'+tr("For each OpenNebula Zone, you can assign cluster resources (set of physical hosts, datastores and virtual networks) to this tenant.")+'</span>\
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
        <div id="req_type" class="tenant_cluster_select hidden">\
            <div class="row collapse ">\
              <div class="large-9 columns">\
               <button id="refresh_tenant_clusters_table_button_class'+str_zone_tab_id+'" type="button" class="refresh button small radius secondary"><i class="fa fa-refresh" /></button>\
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
            <div class="selected_tenant_clusters">\
              <span id="select_tenant_clusters'+str_zone_tab_id+'" class="radius secondary label">'+tr("Please select one or more clusters from the list")+'</span> \
              <span id="you_selected_tenant_clusters'+str_zone_tab_id+'" class="radius secondary label hidden">'+tr("You selected the following clusters:")+'</span> \
            </div>\
            <br>\
        </div\
      </div>\
    </div>';

    $("#refresh_tenant_clusters_table_button_class"+str_zone_tab_id).die();
    $("#refresh_tenant_clusters_table_button_class"+str_zone_tab_id).live('click', function(){
        update_datatable_tenant_clusters(
            $('table[id='+str_datatable_id+']').dataTable(),
            zone_id, str_zone_tab_id, tenant);
    });

    return html;
}

// TODO: Refactor? same function in templates-tab.js
function update_datatable_tenant_clusters(datatable, zone_id, str_zone_tab_id, tenant) {

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

            if (tenant && tenant.RESOURCE_PROVIDER)
            {
                var rows = datatable.fnGetNodes();
                providers_array = tenant.RESOURCE_PROVIDER;

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

var add_resource_tab = function(zone_id, zone_name, dialog, selected_tenant_clusters, tenant) {
    var str_zone_tab_id  = dialog.attr('id') + '_zone' + zone_id;
    var str_datatable_id = dialog.attr('id') + '_datatable_tenant_clusters_zone_' + zone_id;

    selected_tenant_clusters[zone_id] = {};

    // Append the new div containing the tab and add the tab to the list
    var html_tab_content = '<div id="'+str_zone_tab_id+'Tab" class="content">'+
        generate_tenant_resource_tab_content(str_zone_tab_id, str_datatable_id, zone_id, tenant) +
        '</div>'
    $(html_tab_content).appendTo($(".tenant_zones_tabs_content", dialog));

    var a = $("<dd>\
        <a id='zone_tab"+str_zone_tab_id+"' href='#"+str_zone_tab_id+"Tab'>"+zone_name+"</a>\
        </dd>").appendTo($("dl#tenant_zones_tabs", dialog));

    // TODOO
    //$(document).foundationTabs("set_tab", a);
    $("dl#tenant_zones_tabs", dialog).children("dd").first().children("a").click();

    var zone_section = $('#' +str_zone_tab_id+'Tab', dialog);
    setup_tenant_resource_tab_content(zone_id, zone_section, str_zone_tab_id, str_datatable_id, selected_tenant_clusters, tenant);
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
function setupCreateTenantDialog(){
    dialogs_context.append('<div id="create_tenant_dialog"></div>');
    $create_tenant_dialog = $('#create_tenant_dialog',dialogs_context);
    var dialog = $create_tenant_dialog;

    dialog.html(create_tenant_tmpl('create'));
    dialog.addClass("reveal-modal large max-height").attr("data-reveal", "");
    $(document).foundation();

    // Hide update buttons
    $('#update_tenant_submit',$create_tenant_dialog).hide();
    $('#update_tenant_header',$create_tenant_dialog).hide();

    setupTips($create_tenant_dialog);

    $('#create_tenant_reset_button').click(function(){
        $create_tenant_dialog.html("");
        setupCreateTenantDialog();

        popUpCreateTenantDialog();
    });

    setupCustomAuthDialog(dialog);

    $('input#name', dialog).change(function(){
        var val = $(this).val();
        var dialog = $create_tenant_dialog;

        $('#username',dialog).val(val + "-admin");
    });

    $('input#admin_user', dialog).change(function(){
        var dialog = $create_tenant_dialog;
        if ($(this).prop('checked')) {
            enableAdminUser(dialog);

            $.each($('[id^="tenant_admin_res"]', dialog), function(){
                $(this).removeAttr("disabled");
            });
        } else {
            disableAdminUser(dialog);

            $.each($('[id^="tenant_admin_res"]', dialog), function(){
                $(this).attr('disabled', 'disabled');
            });
        }
    });

    disableAdminUser(dialog);

    $.each($('[id^="tenant_res"]', dialog), function(){
        $(this).prop("checked", true);
    });

    $.each($('[id^="tenant_admin_res"]', dialog), function(){
        $(this).attr('disabled', 'disabled');
        $(this).prop("checked", true);
    });

    $("#tenant_res_net", dialog).prop("checked", false);
    $("#tenant_admin_res_net", dialog).prop("checked", false);

    var selected_tenant_clusters = {};

    OpenNebula.Zone.list({
        timeout: true,
        success: function (request, obj_list){
            $.each(obj_list,function(){
                add_resource_tab(this.ZONE.ID,
                    this.ZONE.NAME,
                    dialog,
                    selected_tenant_clusters);
            });
        },
        error: onError
    });

    $('#create_tenant_form',dialog).submit(function(){
        var name = $('#name',this).val();

        var user_json = null;

        if ( $('#admin_user', this).prop('checked') ){
            user_json = buildUserJSON(this);    // from users-tab.js

            if (!user_json) {
                notifyError(tr("User name and password must be filled in"));
                return false;
            }
        }

        var tenant_json = {
            "tenant" : {
                "name" : name
            }
        };

        if (user_json){
            tenant_json["tenant"]["tenant_admin"] = user_json["user"];
        }

        tenant_json['tenant']['resource_providers'] = [];

        $.each(selected_tenant_clusters, function(zone_id, zone_clusters) {
            var str_zone_tab_id = dialog.attr('id') + '_zone' + zone_id;

            var resource_selection = $("input[name='"+str_zone_tab_id+"']:checked", dialog).val();
            switch (resource_selection){
            case "all":
                // 10 is the special ID for ALL, see ClusterPool.h
                tenant_json['tenant']['resource_providers'].push(
                    {"zone_id" : zone_id, "cluster_id" : 10}
                );

                break;
            case "cluster":
                $.each(selected_tenant_clusters[zone_id], function(key, value) {
                    tenant_json['tenant']['resource_providers'].push(
                        {"zone_id" : zone_id, "cluster_id" : key}
                    );
                });

                break;
            default: // "none"

            }
        });

        var resources = "";
        var separator = "";

        $.each($('[id^="tenant_res"]:checked', dialog), function(){
            resources += (separator + $(this).val());
            separator = "+";
        });

        tenant_json['tenant']['resources'] = resources;

        if (user_json){
            resources = "";
            separator = "";

            $.each($('[id^="tenant_admin_res"]:checked', dialog), function(){
                resources += (separator + $(this).val());
                separator = "+";
            });

            tenant_json["tenant"]["tenant_admin"]["resources"] = resources;
        }

        tenant_json['tenant']['views'] = [];

        $.each($('[id^="tenant_view"]:checked', dialog), function(){
            tenant_json['tenant']['views'].push($(this).val());
        });


        Sunstone.runAction("Tenant.create",tenant_json);
        return false;
    });
}

function popUpCreateTenantDialog(){
    $create_tenant_dialog.foundation().foundation('reveal', 'open');
    $("input#name",$create_tenant_dialog).focus();
}

//Prepares the dialog to update
function setupUpdateTenantDialog(){
    if (typeof($update_tenant_dialog) !== "undefined"){
        $update_tenant_dialog.html("");
    }

    dialogs_context.append('<div id="update_tenant_dialog"></div>');
    $update_tenant_dialog = $('#update_tenant_dialog',dialogs_context);
    var dialog = $update_tenant_dialog;

    dialog.html(create_tenant_tmpl('update'));
    dialog.addClass("reveal-modal large max-height").attr("data-reveal", "");
    $(document).foundation();

    setupTips($update_tenant_dialog);

    // Hide create button
    $('#create_tenant_submit',$update_tenant_dialog).hide();
    $('#create_tenant_header',$update_tenant_dialog).hide();
    $('#create_tenant_reset_button',$update_tenant_dialog).hide();

    // Disable parts of the wizard
    $("input#name", dialog).attr("disabled", "disabled");

    $("a[href='#administrators']", dialog).parents("dd").hide();
    $("a[href='#resource_creation']", dialog).parents("dd").hide();

    $update_tenant_dialog.foundation();
}

function initUpdateTenantDialog(){
    var selected_nodes = getSelectedNodes(dataTable_tenants);

    if ( selected_nodes.length != 1 )
    {
        notifyMessage("Please select one (and just one) tenant to update.");
        return false;
    }

    // Get proper id
    var tenant_id = ""+selected_nodes[0];

    setupUpdateTenantDialog();

    Sunstone.runAction("Tenant.show_to_update", tenant_id);
}

function popUpUpdateTenantDialog(tenant, dialog)
{
    var dialog = $update_tenant_dialog;

    dialog.foundation('reveal', 'open');

    $("input#name",$update_tenant_dialog).val(tenant.NAME);

    var views_str = "";

    if (tenant.TEMPLATE.SUNSTONE_VIEWS){
        views_str = tenant.TEMPLATE.SUNSTONE_VIEWS;

        var views = views_str.split(",");
        $.each(views, function(){
            $('input[id^="tenant_view"][value="'+this.trim()+'"]', dialog).attr('checked','checked');
        });
    }

    var selected_tenant_clusters = {};

    OpenNebula.Zone.list({
        timeout: true,
        success: function (request, obj_list){
            $.each(obj_list,function(){
                add_resource_tab(this.ZONE.ID,
                                 this.ZONE.NAME,
                                 dialog,
                                 selected_tenant_clusters,
                                 tenant);
            });
        },
        error: onError
    });


    $(dialog).off("click", 'button#update_tenant_submit');
    $(dialog).on("click", 'button#update_tenant_submit', function(){

        // Update Views
        //-------------------------------------
        var new_views_str = "";
        var separator     = "";

        $.each($('[id^="tenant_view"]:checked', dialog), function(){
            new_views_str += (separator + $(this).val());
            separator = ",";
        });

        if (new_views_str != views_str){
            var template_json = tenant.TEMPLATE;
            delete template_json["SUNSTONE_VIEWS"];
            template_json["SUNSTONE_VIEWS"] = new_views_str;

            var template_str = convert_template_to_string(template_json);

            Sunstone.runAction("Tenant.update_template",tenant.ID,template_str);
        }

        // Update Resource Providers
        //-------------------------------------

        var old_resource_providers = tenant.RESOURCE_PROVIDER;

        if (!old_resource_providers) {
            old_resource_providers = new Array();
        } else if (!$.isArray(old_resource_providers)) {
            old_resource_providers = [old_resource_providers];
        }

        var new_resource_providers = [];

        $.each(selected_tenant_clusters, function(zone_id, zone_clusters) {
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
                $.each(selected_tenant_clusters[zone_id], function(key, value) {
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

                Sunstone.runAction("Tenant.del_provider_action",
                                   tenant.ID,
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

                Sunstone.runAction("Tenant.add_provider_action",
                                   tenant.ID,
                                   extra_param);
            }
        });

        // Close the dialog
        //-------------------------------------

        dialog.foundation('reveal', 'close');

        return false;
    });

}

// Add tenants quotas dialog and calls common setup() in sunstone utils.
function setupTenantQuotasDialog(){
    dialogs_context.append('<div title="'+tr("Tenant quotas")+'" id="tenant_quotas_dialog"></div>');
    $tenant_quotas_dialog = $('#tenant_quotas_dialog',dialogs_context);
    var dialog = $tenant_quotas_dialog;
    dialog.html(tenant_quotas_tmpl);

    setupQuotasDialog(dialog);
}

function popUpTenantQuotasDialog(){
    popUpQuotasDialog($tenant_quotas_dialog, 'Tenant', tenantElements())
}

$(document).ready(function(){
    var tab_name = 'tenants-tab';

    if (Config.isTabEnabled(tab_name)) {
      dataTable_tenants = $("#datatable_tenants",main_tabs_context).dataTable({
            "bSortClasses" : false,
            "bDeferRender": true,
            "aoColumnDefs": [
              { "bSortable": false, "aTargets": ["check",4,5,6] },
              { "sWidth": "35px", "aTargets": [0] },
              { "bVisible": true, "aTargets": Config.tabTableColumns(tab_name)},
              { "bVisible": false, "aTargets": ['_all']}
          ]
      });

      $('#tenant_search').keyup(function(){
        dataTable_tenants.fnFilter( $(this).val() );
      })

      dataTable_tenants.on('draw', function(){
        recountCheckboxes(dataTable_tenants);
      })

      Sunstone.runAction("Tenant.list");
      setupCreateTenantDialog();
      setupTenantQuotasDialog();

      initCheckAllBoxes(dataTable_tenants);
      tableCheckboxesListener(dataTable_tenants);
      infoListener(dataTable_tenants, 'Tenant.show');

      $('div#tenants_tab div.legend_div').hide();
      $('div#tenants_tab_non_admin div.legend_div').hide();

      dataTable_tenants.fnSort( [ [1,config['user_config']['table_order']] ] );
    }
})
