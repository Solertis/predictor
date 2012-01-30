require ::File.expand_path('../spec_helper', __FILE__)

describe Recommendify::Base do

  before(:each) do
    flush_redis!
    Recommendify::Base.class_variable_set(:@@max_neighbors, nil)
    Recommendify::Base.class_variable_set(:@@input_matrices, {})
  end

  describe "configuration" do

    it "should return default max_neighbors if not configured" do
      Recommendify::DEFAULT_MAX_NEIGHBORS.should == 50      
      sm = Recommendify::Base.new
      sm.max_neighbors.should == 50
    end
      
    it "should remember max_neighbors if configured" do
      Recommendify::Base.max_neighbors(23)
      sm = Recommendify::Base.new      
      sm.max_neighbors.should == 23
    end

    it "should add an input_matrix by 'key'" do
      Recommendify::Base.input_matrix(:myinput, :similarity_func => :jaccard)
      Recommendify::Base.class_variable_get(:@@input_matrices).keys.should == [:myinput]
    end

    it "should retrieve an input_matrix on a new instance" do
      Recommendify::Base.input_matrix(:myinput, :similarity_func => :jaccard)
      sm = Recommendify::Base.new
      lambda{ sm.myinput }.should_not raise_error
    end

    it "should retrieve an input_matrix on a new instance and correctly overload respond_to?" do
      Recommendify::Base.input_matrix(:myinput, :similarity_func => :jaccard)
      sm = Recommendify::Base.new
      sm.respond_to?(:process!).should be_true
      sm.respond_to?(:myinput).should be_true
      sm.respond_to?(:fnord).should be_false
    end

    it "should retrieve an input_matrix on a new instance and intialize the correct class" do
      Recommendify::Base.input_matrix(:myinput, :similarity_func => :jaccard)
      sm = Recommendify::Base.new
      sm.myinput.should be_a(Recommendify::JaccardInputMatrix)
    end

  end

  describe "process_item!" do

    it "should call similarities_for on each input_matrix" do
      Recommendify::Base.input_matrix(:myfirstinput, :similarity_func => :jaccard)
      Recommendify::Base.input_matrix(:mysecondinput, :similarity_func => :jaccard)
      sm = Recommendify::Base.new
      sm.myfirstinput.should_receive(:similarities_for).with("fnorditem").and_return([["fooitem",0.5]])
      sm.mysecondinput.should_receive(:similarities_for).with("fnorditem").and_return([["fooitem",0.5]])
      sm.similarity_matrix.stub!(:update)
      sm.process_item!("fnorditem")
    end

    it "should call similarities_for on each input_matrix and add all outputs to the similarity matrix" do
      Recommendify::Base.input_matrix(:myfirstinput, :similarity_func => :test, 
        :all_items => ["fnorditem", "fooitem"],
        :similarities_for => [["fooitem",0.5]]
      )
      Recommendify::Base.input_matrix(:mysecondinput, :similarity_func => :test, 
        :all_items => ["fnorditem", "fooitem"],
        :similarities_for => [["fooitem",0.75]]
      )
      sm = Recommendify::Base.new
      sm.similarity_matrix.should_receive(:update).with("fnorditem", [["fooitem",0.5],["fooitem",0.75]])
      sm.process_item!("fnorditem")
    end

    it "should call similarities_for on each input_matrix and add all outputs to the similarity matrix with weight" do
      Recommendify::Base.input_matrix(:myfirstinput, :similarity_func => :test, 
        :all_items => ["fnorditem", "fooitem"],
        :similarities_for => [["fooitem",0.5]]
      )
      Recommendify::Base.input_matrix(:mysecondinput, :similarity_func => :test, 
        :all_items => ["fnorditem", "fooitem"],
        :similarities_for => [["fooitem",0.75]]
      )
      sm = Recommendify::Base.new
      sm.similarity_matrix.should_receive(:update).with("fnorditem", [["fooitem",0.5],["fooitem",2.0]])
      sm.process_item!("fnorditem")
    end

    it "should retrieve all items from all input matrices" do
      Recommendify::Base.input_matrix(:anotherinput, :similarity_func => :test, :all_items => ["foo", "bar"])
      Recommendify::Base.input_matrix(:yetanotherinput, :similarity_func => :test, :all_items => ["fnord", "shmoo"])
      sm = Recommendify::Base.new    
      sm.all_items.length.should == 4
      sm.all_items.should include("foo")
      sm.all_items.should include("bar")
      sm.all_items.should include("fnord")
      sm.all_items.should include("shmoo")
    end

    it "should retrieve all items from all input matrices (uniquely)" do
      Recommendify::Base.input_matrix(:anotherinput, :similarity_func => :test, :all_items => ["foo", "bar"])
      Recommendify::Base.input_matrix(:yetanotherinput, :similarity_func => :test, :all_items => ["fnord", "bar"])
      sm = Recommendify::Base.new    
      sm.all_items.length.should == 3
      sm.all_items.should include("foo")
      sm.all_items.should include("bar")
      sm.all_items.should include("fnord")
    end

  end

  describe "process!" do

    it "should call process_item for all input_matrix.all_items's" do
      Recommendify::Base.input_matrix(:anotherinput, :similarity_func => :test, :all_items => ["foo", "bar"])
      Recommendify::Base.input_matrix(:yetanotherinput, :similarity_func => :test, :all_items => ["fnord", "shmoo"])
      sm = Recommendify::Base.new    
      sm.should_receive(:process_item!).exactly(4).times
      sm.process!
    end

    it "should call process_item for all input_matrix.all_items's (uniquely)" do
      Recommendify::Base.input_matrix(:anotherinput, :similarity_func => :test, :all_items => ["foo", "bar"])
      Recommendify::Base.input_matrix(:yetanotherinput, :similarity_func => :test, :all_items => ["fnord", "bar"])
      sm = Recommendify::Base.new    
      sm.should_receive(:process_item!).exactly(3).times
      sm.process!
    end

  end

  describe "for(item_id)" do

    it "should retrieve the n-most similar neighbors"

    it "should retrieve the n-most similar neighbors in the correct order"

    it "should retrieve the n-most similar neighbors in the correct order as Recommendify::Result objects"

    it "should return an empty array if the item if no neighbors were found"

    it "should return an empty array if the item is unknown"

  end

end
