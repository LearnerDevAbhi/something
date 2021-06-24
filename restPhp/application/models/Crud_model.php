<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

class Crud_model extends CI_Model
{
    function __construct()
    {
        parent::__construct();
        $this->load->database();
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
    public function getKyc($table,$condition=''){
        $this->db->select('ud.*,b.bank_name,b.bank_city,b.accno,b.ifsc,b.is_bankVerified,b.acc_holderName');
        $this->db->from($table);
        $this->db->join('bank_details b','b.user_detail_id=ud.id','left');
        if(!empty($condition))
            $this->db->where($condition);
        $query = $this->db->get();
        return $query->row();
    }
}


?>
