module Arel
  module Visitors
    class SybaseSQLAnywhere < Arel::Visitors::ToSql

      private
      def visit_Arel_Nodes_SelectStatement o
        [
          (visit(o.with) if o.with),
          o.cores.map { |x| visit_Arel_Nodes_SelectCore x, o.limit, o.offset }.join,
          ("ORDER BY #{o.orders.map { |x| visit x }.join(', ')}" unless o.orders.empty?),
          (visit(o.lock) if o.lock),
        ].compact.join ' '
      end

      def visit_Arel_Nodes_SelectCore o, limit=nil, offset=nil
        [
          "SELECT",
          (visit(o.set_quantifier) if o.set_quantifier),
          (visit(o.top) if o.top),
          (visit(limit) if limit),
          (visit(offset) if offset),
          ("#{o.projections.map { |x| visit x }.join ', '}" unless o.projections.empty?),
          ("FROM #{visit(o.source)}" if o.source && !o.source.empty?),
          ("WHERE #{o.wheres.map { |x| visit x }.join ' AND ' }" unless o.wheres.empty?),
          ("GROUP BY #{o.groups.map { |x| visit x }.join ', ' }" unless o.groups.empty?),
          (visit(o.having) if o.having),
        ].compact.join ' '
      end
      
      def visit_Arel_Nodes_Offset o
        "START AT #{visit(o.expr).to_i+1}"
      end
      def visit_Arel_Nodes_Limit o
        "TOP #{visit o.expr}"
      end
    end
  end
end