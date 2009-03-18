require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'render_template' do
  include FunctionalBuilder

  def render_and_validate(options={})
    build_response { render options }
    render_template(options.delete(:action))
  end

  describe 'messages' do
    before(:each) do
      build_response { render :action => 'new' }
      @matcher = render_template('edit')
    end

    it 'should contain a description message' do
      @matcher.description.should == 'render template "edit"'

      @matcher.with_layout('application')
      @matcher.description.should == 'render template "edit" with layout "application"'

      @matcher.with_layout(nil)
      @matcher.description.should == 'render template "edit" with no layout'

      # Now description when @expected is nil
      @matcher = render_template

      @matcher.with_layout('application')
      @matcher.description.should == 'render template  with layout "application"'

      @matcher.with_layout(nil)
      @matcher.description.should == 'render template  with no layout'
    end

    it 'should set render? message' do
      build_response
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected template "edit" to be rendered, got no render'
      @matcher.negative_failure_message.should == 'Did not expect template "edit" to be rendered, got no render'
    end

    # Is not possible to check extensions on Rails 2.1
    unless RAILS_VERSION =~ /^2.1/
      it 'should set expected_match? message' do
        @matcher.matches?(@controller)
        @matcher.failure_message.should == 'Expected template "edit" to be rendered, got "examples/new.html.erb"'
      end
    end

    it 'should set layout_match? message' do
      @matcher = render_template('new')
      @matcher.with_layout('users').matches?(@controller)
      @matcher.failure_message.should == 'Expected template to be rendered with layout "users", got nil'
    end
  end

  describe 'matcher' do

    [ :controller, :response ].each do |subject_name|
      describe "with #{subject_name} subject" do

        describe 'rendering a template' do
          before(:each) do
            build_response { render :action => :new }
            @subject = instance_variable_get("@#{subject_name}")
          end

          it { @subject.should render_template('new') }
          it { @subject.should render_template('new.html') }
          it { @subject.should render_template('new.html.erb') }
          it { @subject.should render_template('examples/new') }
          it { @subject.should render_template('examples/new.html') }
          it { @subject.should render_template('examples/new.html.erb') }

          it { @subject.should_not render_template('edit') }
          it { @subject.should_not render_template('projects/new') }
          it { @subject.should_not render_template('examples/edit') }
        end

        describe 'rendering a template with path' do
          before(:each) do
            build_response { render :template => 'projects/new' }
            @subject = instance_variable_get("@#{subject_name}")
          end

          it { @subject.should render_template('projects/new') }
          it { @subject.should render_template('projects/new.html') }
          it { @subject.should render_template('projects/new.html.erb') }

          it { @subject.should_not render_template('new') }
          it { @subject.should_not render_template('examples/new') }
          it { @subject.should_not render_template('projects/edit') }
        end

        describe 'rendering a template with extention xml.builder' do
          before(:each) do
            build_response { respond_to{ |format| format.xml } }
            @subject = instance_variable_get("@#{subject_name}")
          end

          it { @subject.should render_template('example') }
          it { @subject.should render_template('example.xml') }
          it { @subject.should render_template('example.xml.builder') }
          it { @subject.should render_template('examples/example') }
          it { @subject.should render_template('examples/example.xml') }
          it { @subject.should render_template('examples/example.xml.builder') }

          # Is not possible to check extensions on Rails 2.1
          unless RAILS_VERSION =~ /^2.1/
            it { @subject.should_not render_template('example.html') }
            it { @subject.should_not render_template('example.html.erb') }
            it { @subject.should_not render_template('example.html.builder') }
            it { @subject.should_not render_template('examples/example.html') }
            it { @subject.should_not render_template('examples/example.html') }
            it { @subject.should_not render_template('examples/example.html.erb') }
          end
        end

        describe 'rendering a partial' do
          before(:each) do
            build_response { render :partial => 'example' }
            @subject = instance_variable_get("@#{subject_name}")
          end

          it { @subject.should render_template('_example') }
          it { @subject.should render_template('_example.html') }
          it { @subject.should render_template('_example.html.erb') }
          it { @subject.should render_template('examples/_example') }
          it { @subject.should render_template('examples/_example.html') }
          it { @subject.should render_template('examples/_example.html.erb') }

          it { @subject.should_not render_template('example') }
          it { @subject.should_not render_template('example.html') }
          it { @subject.should_not render_template('example.html.erb') }
          it { @subject.should_not render_template('examples/example') }
          it { @subject.should_not render_template('examples/example.html') }
          it { @subject.should_not render_template('examples/example.html.erb') }
        end

      end
    end

    describe 'with with_layout option' do
      it { should render_and_validate.with_layout(nil) }
      it { should render_and_validate(:layout => 'examples').with_layout('examples') }
      it { should_not render_and_validate(:layout => 'examples').with_layout('users') }
      it { should_not render_and_validate(:layout => 'examples').with_layout(nil) }

      it { render_and_validate; should render_without_layout }
      it { render_and_validate(:layout => 'examples'); should render_with_layout('examples') }
      it { render_and_validate(:layout => 'examples'); should_not render_with_layout('users') }
      it { render_and_validate(:layout => 'examples'); should_not render_with_layout(nil) }
    end

  end

  describe 'macro' do

    describe 'rendering a template' do
      before(:each) { build_response { render :action => :new } }

      should_render_template 'new'
      should_render_template 'new.html'
      should_render_template 'new.html.erb'
      should_render_template 'examples/new'
      should_render_template 'examples/new.html'
      should_render_template 'examples/new.html.erb'

      should_not_render_template 'edit'
      should_not_render_template 'projects/new'
      should_not_render_template 'examples/edit'
    end

    describe 'rendering a template with path' do
      before(:each) { build_response { render :template => 'projects/new' } }

      should_render_template 'projects/new'
      should_render_template 'projects/new.html'
      should_render_template 'projects/new.html.erb'

      should_not_render_template 'new'
      should_not_render_template 'examples/new'
      should_not_render_template 'projects/edit'
    end

    describe 'rendering a template with extention xml.builder' do
      before(:each) { build_response { respond_to{ |format| format.xml } } }

      should_render_template 'example'
      should_render_template 'example.xml'
      should_render_template 'example.xml.builder'
      should_render_template 'examples/example'
      should_render_template 'examples/example.xml'
      should_render_template 'examples/example.xml.builder'

      # Is not possible to check extensions on Rails 2.1
      unless RAILS_VERSION =~ /^2.1/
        should_not_render_template 'example.html'
        should_not_render_template 'example.html.erb'
        should_not_render_template 'example.html.builder'
        should_not_render_template 'examples/example.html'
        should_not_render_template 'examples/example.html'
        should_not_render_template 'examples/example.html.erb'
      end
    end

    describe 'rendering a partial' do
      before(:each) { build_response { render :partial => 'example' } }

      should_render_template '_example'
      should_render_template '_example.html'
      should_render_template '_example.html.erb'
      should_render_template 'examples/_example'
      should_render_template 'examples/_example.html'
      should_render_template 'examples/_example.html.erb'

      should_not_render_template 'example'
      should_not_render_template 'example.html'
      should_not_render_template 'example.html.erb'
      should_not_render_template 'examples/example'
      should_not_render_template 'examples/example.html'
      should_not_render_template 'examples/example.html.erb'
    end

  end

end
