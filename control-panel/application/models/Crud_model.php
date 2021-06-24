<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

class Crud_model extends CI_Model
{

    function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library('bcrypt');
    } 

    public function GetData($table,$field='',$condition='',$group='',$order='',$limit='',$result='')
    {
        if($field != '')
            $this->db->select($field);
        if($condition != '')
            $this->db->where($condition);
        if($order != '')
            $this->db->order_by($order);
        if($limit != '')
            $this->db->limit($limit);
        if($group != '')
            $this->db->group_by($group);
        if($result != '')
        {
            $return =  $this->db->get($table)->row();
        }else{
            $return =  $this->db->get($table)->result();
        }
        return $return;
    }

    public function GetDataArr($table,$field='',$condition='',$group='',$order='',$limit='',$result='')
    {
        if($field != '')
            $this->db->select($field);
        if($condition != '')
            $this->db->where($condition);
        if($order != '')
            $this->db->order_by($order);
        if($limit != '')
            $this->db->limit($limit);
        if($group != '')
            $this->db->group_by($group);
        if($result != '')
        {
            $return =  $this->db->get($table)->row_array();
        }else{
            $return =  $this->db->get($table)->result_array();
        }
        return $return;
    }
    
    public function SaveData($table,$data='',$condition='')
    {
        $DataArray = array();
        if(!empty($data))
        { 
            if(!empty($condition))
            {
                $data['modified']=date("Y-m-d H:i:s");
            }
            else
            {
                $data['created']=date("Y-m-d H:i:s");
                $data['modified']=date("Y-m-d H:i:s");
            }
        }
        $table_fields = $this->db->list_fields($table);
        foreach($data as $field=>$value)
        {
            if(in_array($field,$table_fields))
            {
                $DataArray[$field]= $value;
            }
        }

        if($condition != '')
        {
            $this->db->where($condition);
            $this->db->update($table, $DataArray);

        }else{
            $this->db->insert($table, $DataArray);
        }
    }

    public function DeleteData($table,$condition='',$limit='')
    {
        if($condition != '')
            $this->db->where($condition);
        if($limit != '')
            $this->db->limit($limit);
        $this->db->delete($table);
    }

    public function getSingleData($tablename,$condition)
    {
        $this->db->where($condition);
        return $this->db->get($tablename)->row();
    }
    function get_single($table, $cond='')
    {   
        if($cond != '')
            $this->db->where($cond);
        return $this->db->get($table)->row();
    }
    function get_by_id_table($table, $condition)
    {
        $this->db->where($condition);
        return $this->db->get($table)->row();
    }
    function GetIndividualInfo($table,$cond)
    {
        $this->db->where($cond);
        return $this->db->get($table)->row();
    }


    function alterTable($table, $fieldOne = '',$fieldTwo = '',$originalField = '', $dropField = '')
    {
        if($fieldTwo != '')
        {
            $this->db->query("alter table ".$table." add ".$fieldOne." after ".$fieldTwo." ");
        }
        else if($originalField != '')
        {
            $this->db->query("alter table ".$table." CHANGE ".$originalField." ".$fieldOne." ");
        }
        else
        {
            $this->db->query("alter table ".$table." drop ".$dropField."");
        }
    }

    //get data
    public function GetDataAll($table,$condition='',$order='',$group='',$limit='',$distinct='')
    {   
        if($distinct !='')
            $this->db->distinct($distinct);
        if($condition != '')
            $this->db->where($condition);
        if($order != '')
            $this->db->order_by($order);
        if($limit != '')
            $this->db->limit($limit);
        if($group != '')
            $this->db->group_by($group);
        return $this->db->get($table)->result();
    }

    function get_data_submenu($table,$con,$order='',$limit='',$group='')
    {
        if($con!='')
            $this->db->where($con);
        if($order != '')
            $this->db->order_by($order);
        if($limit != '')
            $this->db->limit($limit);
        if($group != '')
            $this->db->group_by($group);
        return $this->db->get($table)->row();
    }

      function compress_image($source, $destination, $quality)
    {
        $info = getimagesize($source);

        if ($info['mime'] == 'image/jpeg') 
            $image = imagecreatefromjpeg($source);

        elseif ($info['mime'] == 'image/gif') 
            $image = imagecreatefromgif($source);

        elseif ($info['mime'] == 'image/png') 
            $image = imagecreatefrompng($source);

        elseif ($info['mime'] == 'image/jpg') 
            $image = imagecreatefrompng($source);

        elseif ($info['mime'] == 'image/JPEG') 
            $image = imagecreatefrompng($source);

        elseif ($info['mime'] == 'image/GIF') 
            $image = imagecreatefrompng($source);

        elseif ($info['mime'] == 'image/PNG') 
            $image = imagecreatefrompng($source);

        elseif ($info['mime'] == 'image/JPG') 
            $image = imagecreatefrompng($source);

        imagejpeg($image,$destination,$quality);

        return $destination;
    }


     public function multijoin($table,$field='',$condition='',$group='',$order='',$limit='',$tables='',$joincon='',$jointype='',$result='')  
    {
        if($field != '')
        $this->db->select($field);
        if($condition != '')
        $this->db->where($condition);
        if($order != '')
        $this->db->order_by($order);
        if($limit != '')
        $this->db->limit($limit);
        if($group != '')
        $this->db->group_by($group);

        for ($i=0; $i <count($tables); $i++)
        {
            $this->db->join($tables[$i], $joincon[$i],$jointype[$i]);
        }
        if($result != '')
        {
            $return =  $this->db->get($table)->row();
        }else{
            $return =  $this->db->get($table)->result();
        }
        return $return;
    } 
    

    public function get_multiple_record($table,$fields='', $con='',$order='',$group='',$limit='')
    {
        if($fields!='')
        $this->db->select($fields);
        if($con!='')
        $this->db->where($con);
        if($order!='')
        $this->db->order_by($order);
        if($group!='')
        $this->db->group_by($group);
        if($limit!='')
        $this->db->limit($limit);

        return $this->db->get($table)->result();
    }


    public function GetTodatKyc($condition){
        $this->db->select('u.id');
        $this->db->from("user_details u");    
        $this->db->join('bank_details b','u.id=b.user_detail_id','left');
        $this->db->where($condition);
        $query = $this->db->get();
        return $query->result();
    }

    public function getMenuData(){
        return $this->db->query("SELECT a.menuId,a.menuName,a.menuIcon mainIcon,a.menuConstant mainConstant,
            GROUP_CONCAT(b.menuConstant) menuConstant,
            GROUP_CONCAT(b.menuIcon) menuIcon,
            GROUP_CONCAT(b.menuName) subMenuName,
            COUNT(b.menuId) countChild,
            CASE WHEN COUNT(b.menuId) > 0 THEN TRUE ELSE FALSE END `open`
            FROM admin_menus a
            LEFT JOIN admin_menus b ON a.menuId = b.parentId
            where a.parentId =0
            GROUP BY a.menuId, a.menuName")->result_array();
      
    }

    public function userMenuData($id){
        return $this->db->query("SELECT mm.menuId,am.menuName,am.menuIcon mainIcon,am.menuConstant mainConstant,count(am2.parentId) countChild,
            group_concat(am2.menuConstant) menuConstant, 
            group_concat(am2.menuIcon) menuIcon, 
            group_concat(am2.menuName) subMenuName
            from admin_menu_mapping mm
            left join admin_menus am on am.menuId=mm.menuId
            left join admin_menus am2 on am2.menuId=mm.subMenuId 
            where mm.adminId=$id
            group by mm.menuId;")->result_array();
      
    }
}


?>
