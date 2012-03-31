# encoding: utf-8

##
# Oedipus Sphinx 2 Search.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

require "spec_helper"

describe Oedipus::QueryBuilder do
  let(:builder) { Oedipus::QueryBuilder.new(:posts) }

  describe "#select" do
    context "with a fulltext search" do
      it "uses MATCH()" do
        builder.select("dogs AND cats", {}).should =~ /SELECT .* FROM posts WHERE MATCH\('dogs AND cats'\)/
      end
    end

    context "without conditions" do
      it "does not add a where clause" do
        builder.select("", {}).should_not =~ /WHERE/
      end
    end

    context "with equal attribute filters" do
      it "uses the '=' operator" do
        builder.select("dogs", author_id: 7).should =~ /SELECT .* FROM posts WHERE .* author_id = 7/
      end
    end

    context "with not equal attribute filters" do
      it "uses the '!=' operator" do
        builder.select("dogs", author_id: Oedipus.not(7)).should =~ /SELECT .* FROM posts WHERE .* author_id != 7/
      end
    end

    context "with inclusive range-filtered attribute filters" do
      it "uses the BETWEEN operator" do
        builder.select("cats", views: 10..20).should =~ /SELECT .* FROM posts WHERE .* views BETWEEN 10 AND 20/
      end
    end

    context "with exclusive range-filtered attribute filters" do
      it "uses the BETWEEN operator" do
        builder.select("cats", views: 10...20).should =~ /SELECT .* FROM posts WHERE .* views BETWEEN 10 AND 19/
      end
    end

    context "with a greater than or equal comparison" do
      it "uses the >= operator" do
        builder.select("cats", views: 50..(1/0.0)).should =~ /SELECT .* FROM posts WHERE .* views >= 50/
      end
    end

    context "with a greater than comparison" do
      it "uses the > operator" do
        builder.select("cats", views: 50...(1/0.0)).should =~ /SELECT .* FROM posts WHERE .* views > 50/
      end
    end

    context "with a less than or equal comparison" do
      it "uses the <= operator" do
        builder.select("cats", views: -(1/0.0)..50).should =~ /SELECT .* FROM posts WHERE .* views <= 50/
      end
    end

    context "with a less than comparison" do
      it "uses the < operator" do
        builder.select("cats", views: -(1/0.0)...50).should =~ /SELECT .* FROM posts WHERE .* views < 50/
      end
    end

    context "with a negated range comparison" do
      it "uses the NOT BETWEEN operator" do
        builder.select("cats", views: Oedipus.not(50..100)).should =~ /SELECT .* FROM posts WHERE .* views NOT BETWEEN 50 AND 100/
      end
    end

    context "with a limit" do
      it "applies a LIMIT with an offset of 0" do
        builder.select("dogs", limit: 50).should =~ /SELECT .* FROM posts WHERE .* LIMIT 0, 50/
      end

      it "is not considered an attribute" do
        builder.select("dogs", limit: 50).should_not =~ /limit = 50/
      end
    end

    context "with an offset" do
      it "applies a LIMIT with an offset" do
        builder.select("dogs", limit: 50, offset: 200).should =~ /SELECT .* FROM posts WHERE .* LIMIT 200, 50/
      end

      it "is not considered an attribute" do
        builder.select("dogs", limit: 50, offset: 200).should_not =~ /offset = 200/
      end
    end
  end
end